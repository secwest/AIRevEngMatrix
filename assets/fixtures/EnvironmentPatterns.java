import java.util.function.IntUnaryOperator;

public final class EnvironmentPatterns {
    interface Transform { int apply(int value); }
    static final class Add implements Transform {
        final int amount;
        Add(int amount) { this.amount = amount; }
        public int apply(int value) {
            if (value > 255 - amount) throw new IllegalArgumentException("overflow");
            return value + amount;
        }
    }
    static <T extends Transform> int invoke(T operation, int value) {
        return operation.apply(value);
    }
    public static void main(String[] args) {
        try {
            if (args.length == 0) throw new IllegalArgumentException("missing");
            if (!args[0].matches("[0-9]+")) throw new IllegalArgumentException("invalid");
            int value;
            try { value = Integer.parseInt(args[0]); }
            catch (NumberFormatException error) { throw new IllegalArgumentException("invalid"); }
            if (value > 255) throw new IllegalArgumentException("invalid");
            Transform operation = new Add(7);
            IntUnaryOperator closure = n -> invoke(operation, n);
            System.out.println("ok:" + closure.applyAsInt(value));
        } catch (IllegalArgumentException error) {
            System.out.println("err:" + error.getMessage());
        }
    }
}
