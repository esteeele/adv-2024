import day14
import gleam/erlang/os
import gleam/int
import gleam/io
import gleam/list

pub fn main() {
  io.println("Hello from adv!")
  let user_home = os.get_env("RUBY_ENGINE")
  case user_home {
    Ok(v) -> io.println(v)
    Error(_) -> io.println("not found")
  }
  io.debug(list.sort([4, 2, 6, 3, 1], int.compare))

  let result = day14.build_grid(100)
  day14.find_orderliness(result)
  let res = day14.part_2()
  io.debug(res)
}
