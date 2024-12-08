import day2
import day3
import day6
import day7
import gleam/erlang/os
import gleam/int
import gleam/io
import simplifile

pub fn main() {
  io.println("Hello from adv!")
  let user_home = os.get_env("RUBY_ENGINE")
  case user_home {
    Ok(v) -> io.println(v)
    Error(error) -> io.println("not found")
  }

  let res = day7.day7()
  io.debug(res)
}
