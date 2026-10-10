use std::hint::black_box;

#[derive(Debug)]
enum Problem {
    Missing,
    Invalid,
    Overflow,
}

trait Transform {
    fn apply(&self, value: u8) -> Result<u8, Problem>;
}

struct Add {
    amount: u8,
}

impl Transform for Add {
    #[inline(never)]
    fn apply(&self, value: u8) -> Result<u8, Problem> {
        value.checked_add(self.amount).ok_or(Problem::Overflow)
    }
}

#[inline(never)]
fn invoke<T: Transform + ?Sized>(operation: &T, value: u8) -> Result<u8, Problem> {
    operation.apply(value)
}

#[inline(never)]
fn parse_input(text: Option<&str>) -> Result<u8, Problem> {
    text.ok_or(Problem::Missing)?
        .parse::<u8>()
        .map_err(|_| Problem::Invalid)
}

fn main() {
    let input = std::env::args().nth(1);
    let operation = Add { amount: 7 };
    let erased: &dyn Transform = black_box(&operation);
    let result = parse_input(input.as_deref()).and_then(|value| invoke(erased, value));
    match result {
        Ok(value) => println!("ok:{value}"),
        Err(Problem::Missing) => println!("err:missing"),
        Err(Problem::Invalid) => println!("err:invalid"),
        Err(Problem::Overflow) => println!("err:overflow"),
    }
}
