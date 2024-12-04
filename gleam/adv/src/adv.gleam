import day2
import gleam/erlang/os
import gleam/io
import simplifile

pub fn main() {
  io.println("Hello from adv!")
  let user_home = os.get_env("RUBY_ENGINE")
  case user_home {
    Ok(v) -> io.println(v)
    Error(error) -> io.println("not found")
  }

  let assert Ok(_) = simplifile.read("data/input.txt")

  day2.day_2()
}
