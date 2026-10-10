import sys


def evaluate(args):
    if not args:
        raise ValueError("missing")
    text = args[0]
    if not text or any(character not in "0123456789" for character in text):
        raise ValueError("invalid")
    value = int(text)
    if value > 255:
        raise ValueError("invalid")
    amount = 7

    def apply(number):
        if number > 255 - amount:
            raise ValueError("overflow")
        return number + amount

    return apply(value)


if __name__ == "__main__":
    try:
        print(f"ok:{evaluate(sys.argv[1:])}")
    except ValueError as error:
        print(f"err:{error}")
