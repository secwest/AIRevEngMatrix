async function evaluate(args) {
  if (args.length === 0) throw new Error('missing');
  const text = args[0];
  if (!/^[0-9]+$/.test(text)) throw new Error('invalid');
  const value = Number(text);
  if (!Number.isInteger(value) || value > 255) throw new Error('invalid');
  const amount = 7;
  const apply = number => {
    if (number > 255 - amount) throw new Error('overflow');
    return number + amount;
  };
  await Promise.resolve();
  return apply(value);
}

try { console.log(`ok:${await evaluate(process.argv.slice(2))}`); }
catch (error) { console.log(`err:${error.message}`); }
