abstract class Transform { int apply(int value); }
class Add implements Transform {
  final int amount;
  Add(this.amount);
  @override
  int apply(int value) {
    if (value > 255 - amount) throw StateError('overflow');
    return value + amount;
  }
}
int invoke<T extends Transform>(T operation, int value) => operation.apply(value);
Future<int> evaluate(List<String> args) async {
  if (args.isEmpty) throw StateError('missing');
  if (!RegExp(r'^[0-9]+$').hasMatch(args[0])) throw StateError('invalid');
  final value = int.tryParse(args[0]);
  if (value == null || value > 255) throw StateError('invalid');
  final Transform operation = Add(7);
  return await Future<int>(() => invoke(operation, value));
}
Future<void> main(List<String> args) async {
  try { print('ok:${await evaluate(args)}'); }
  on StateError catch (error) { print('err:${error.message}'); }
}
