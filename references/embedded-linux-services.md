# Embedded Linux services

This guide follows an extracted root filesystem from boot to a running service and from the service to its externally visible behavior. It assumes a validated region map from [firmware triage](firmware-triage.md) and an extracted tree with preserved metadata as described in [Firmware](firmware.md). Nothing in the tree is executed on the host. Template: [boot chain](../assets/templates/boot-chain.yaml).

## Which filesystem runs

Before reading `/etc`, establish which tree the device boots.

| Evidence | Where | What it settles |
| --- | --- | --- |
| Kernel command line | Bootloader environment (`bootargs`), FIT configuration, DTB `/chosen/bootargs`, Android boot header | `root=`, `rootfstype=`, `init=`, `ubi.mtd=`, `mtdparts=` select the root and the partition layout |
| Slot selection | U-Boot environment variables, AVB slot metadata, vendor `bootcount`/`upgrade_available` logic | Which of two root images runs; an extracted image may be the inactive slot |
| Overlay order | `/etc/fstab`, `/etc/preinit`, `/sbin/init` scripts, procd `mount_root`, systemd mount units | A JFFS2/UBIFS overlay over a read-only SquashFS replaces files at runtime; the shipped file may not be the effective file |
| Configuration partitions | Partition named `config`, `nvram`, `userdata`, `data`, `rwfs`, `appfs`; U-Boot environment | Settings that change service behavior without changing the image |
| Init selection | `init=` on the command line, `/init` for an initramfs, `/sbin/init` symlink target | Which init family applies |

Record the selected root as a digest and the overlay/config partitions as separate identities with their own digests.

## Init families

| Family | Identify by | Service list | Ordering and conditions |
| --- | --- | --- | --- |
| BusyBox init | `/sbin/init` → `busybox`; `/etc/inittab` | `::sysinit:` and `::respawn:` lines; `/etc/init.d/rcS` running `/etc/rc.d/S??*` or `/etc/init.d/S??*` | Numeric prefix order; `respawn` restarts on exit |
| SysV init | `/etc/inittab` with runlevels; `/etc/rc?.d/` | `S??name` symlinks to `/etc/init.d/name` | Runlevel from `initdefault` or `bootargs`; `K` links stop services |
| OpenWrt procd | `/sbin/procd`; `/etc/init.d/*` with `START=` and `STOP=`; `/etc/rc.d/S??*` symlinks | Scripts with `start_service()` using `procd_open_instance` | `START` number order; `/etc/config/*` via UCI enables or disables instances; `/etc/rc.local` runs last |
| systemd | `/lib/systemd/systemd`; `*.service` units; `*.wants/` directories | Units linked from `multi-user.target.wants`, `sockets.target.wants`, `timers.target.wants` | `After=`, `Requires=`, `ConditionPathExists=`; socket activation starts a service on first connection |
| Android init | `/init` and `*.rc` files; `init.${ro.hardware}.rc` | `service name /path` blocks; `on boot`, `on property:` triggers | `class`, `disabled`, `oneshot`; property triggers; SELinux labels |
| Custom or vendor | A single vendor binary as `init`, or a `startup.sh` invoked by one of the above | Strings and `fork`/`execve` paths in the vendor binary | Often reads a config partition first; record the dependency |

A service appears in the list when its script exists, is linked into the active run order, and is enabled by configuration. Each of these is a separate check.

## Resolve the executable

1. Follow the service script or unit to the command line it runs. Resolve variables set by the script, the environment file, or the configuration store.
2. Resolve symlinks within the extracted tree, never on the host. BusyBox applets, `alternatives`, and vendor wrapper scripts redirect common names.
3. Record the final executable path, its digest, `readelf -h` architecture, interpreter (`PT_INTERP`), and `DT_NEEDED` libraries. A dynamic executable with a missing library in the tree indicates an overlay, a second filesystem, or an incomplete extraction.
4. Record the command-line arguments, working directory, user, capabilities (`getcap` output from extended attributes if the extractor preserved them), and configuration file paths.

## Service families and their dispatch

| Family | Typical executables | Where handlers live | What to record |
| --- | --- | --- | --- |
| HTTP servers | `uhttpd`, `lighttpd`, `boa`, `goahead`, `mini_httpd`, `thttpd`, `appweb`, `nginx`, BusyBox `httpd`, vendor `httpd` | CGI directories (`/www/cgi-bin`, `/usr/www/cgi-bin`), Lua or PHP handlers, compiled handler tables inside a vendor `httpd` (string tables of URL paths next to function pointers) | Listener address and port from config, document root, authentication mechanism, URL-to-handler table with addresses |
| RPC and management | `upnpd`, `miniupnpd`, TR-069/CWMP clients (`cwmpd`, `tr069`), `dropbear`/`sshd`, `telnetd`, vendor management daemons | XML/SOAP action dispatch, UBUS/UCI calls on OpenWrt, D-Bus objects, custom binary command tables | Bound interface and port, authentication and ACL, the action-to-function map, and whether the LAN or WAN interface is served |
| Key-value and config | `nvram` get/set helpers, `envram`, `fw_printenv`/`fw_setenv`, UCI | A shared library or applet read by many services; the backing partition | Which settings reach a network-facing handler and which partition persists them |
| Update and recovery | `sysupgrade`, `mtd write`, vendor OTA clients, `swupdate`, `rauc`, `fwupdate` | The download, verification, and flash-write path | The verifier invoked, the signature or checksum checked, and the slot or partition written; cross-reference the update sections of [Firmware](firmware.md) |
| Discovery and auto-config | `dnsmasq`, `udhcpd`/`udhcpc`, `mdnsd`/`avahi`, `wscd`/WPS, SSDP responders | Request parsers and option handlers | Listener, parsed fields, and any field that reaches a config write or a command execution |
| Telemetry and cloud | MQTT clients (`mosquitto_sub`, vendor agents), vendor phone-home daemons | Connection setup, topic/endpoint strings, message parsers | Destination endpoint, credentials source, and inbound-command handling |

A string or port in a binary is a candidate, not a running path. Confirm the listener is bound, the handler is reached from the parser, and configuration enables the feature before claiming the service exposes it.

## From handler to externally visible behavior

1. Tie each listener to a reachable interface. A service bound to `127.0.0.1` or a LAN bridge is not WAN-reachable without a forwarding rule; check `iptables`/`nftables` rules, UPnP mappings, and the firewall config.
2. Follow the request parser to the handler. For a vendor `httpd`, locate the URL-to-handler table (often an array of `{path, function}` pairs) and resolve each function in the disassembler. For CGI, the path maps to a file or an `execve` of a script.
3. Record input validation and the sinks a tainted field reaches: `system`/`popen`/`exec*`, `nvram_set`, file writes, SQL, and format strings. Keep "string present" separate from "reachable with attacker-controlled input."
4. Record authentication and authorization on the path. A handler reachable before authentication is a different finding from one behind a login.
5. For a remote-reachability or fingerprint claim, tie the signal to a bound listener, the request preconditions, and a repeatable response, and prefer an authorized capture over static inference. Follow [process and reconstruction](process-and-reconstruction.md) for observed traffic.

## Credentials, keys, and secrets

Record, with their file paths and digests, but do not treat presence as use: `/etc/passwd` and `/etc/shadow` hashes, default or hardcoded credentials in scripts and binaries, TLS private keys and certificates, API tokens, Wi-Fi defaults, and WPS PINs. A key in the image shows the key ships, not that a given service loads it; resolve the loader. A hash in `/etc/shadow` for an account with no enabled login shell is a different exposure from one tied to `dropbear` or `telnetd`.

## Component versions and known issues

Identify the actual shipped version of BusyBox, the C library, OpenSSL/wolfSSL/mbedTLS, the web server, and the kernel from the binaries, not only from package strings. Vendors backport fixes and strip version banners, so a version string names a source tree, not a patch state. For any defect claim, separate exposure (the code ships), reachability (a running service reaches it), and exploitability (input and configuration permit it), and support each separately. [Syft](matching-and-runtime-artifacts.md) can inventory the extracted tree; confirm representative identities and preserve stripped or static binaries as unresolved.

## Verification

- A service is "running by default" only when its script exists, is linked into the active run order, is enabled by configuration, and binds a listener. Record which of these was checked.
- A handler address is confirmed by the decisive instructions at the URL table entry and the call into the handler, not by the URL string alone.
- A reachability claim names the interface, the firewall state, and the authentication boundary.
- An overlay or config partition that changes any of the above is recorded with its own digest, because the shipped file may not be the effective file.

## Deliverable

A boot-to-service record in the [boot chain template](../assets/templates/boot-chain.yaml): selected root and overlays with digests, init family, the service's script-to-executable-to-handler path with addresses, listener and interface, authentication boundary, configuration inputs, and the externally visible behavior with its verification state. Unresolved symlinks, missing libraries, and unconfirmed reachability remain explicit.
