using System;
using System.Globalization;
using System.Threading.Tasks;

interface ITransform { int Apply(int value); }

sealed class Add : ITransform
{
    readonly int amount;
    public Add(int amount) { this.amount = amount; }
    public int Apply(int value)
    {
        if (value > 255 - amount) throw new InvalidOperationException("overflow");
        return value + amount;
    }
}

static class EnvironmentPatterns
{
    static int Invoke<T>(T operation, int value) where T : ITransform => operation.Apply(value);
    static async Task<int> Evaluate(string[] args)
    {
        if (args.Length == 0) throw new InvalidOperationException("missing");
        if (!byte.TryParse(args[0], NumberStyles.None, CultureInfo.InvariantCulture, out var value))
            throw new InvalidOperationException("invalid");
        ITransform operation = new Add(7);
        await Task.Yield();
        return Invoke(operation, value);
    }
    static async Task Main(string[] args)
    {
        try { Console.WriteLine("ok:" + await Evaluate(args)); }
        catch (InvalidOperationException error) { Console.WriteLine("err:" + error.Message); }
    }
}
