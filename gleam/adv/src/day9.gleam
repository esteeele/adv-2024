import gleam/int
import gleam/io
import gleam/list
import simplifile
import utils

pub type Block {
  File(address: Int, size: Int, id: Int)
  FreeSpace(address: Int, size: Int)
}

pub fn day9() {
  let assert Ok(contents) = simplifile.read("data/input.txt")
  let files_and_stuff = utils.string_list_to_ints(contents, "")
  let files = parse_line(files_and_stuff, 0, 0, [])
  io.debug(list.length(files))
  let total_size = list.fold(files, 0, fn(acc, block) { acc + block.size })
  io.debug(total_size)
}

fn parse_line(
  files_line: List(Int),
  address: Int,
  invocation: Int,
  acc: List(Block),
) {
  case files_line {
    [] -> acc
    [block, ..tail] -> {
      let mapped_block = case int.is_even(invocation) {
        True -> File(address, block, invocation / 2)
        False -> FreeSpace(address, block)
      }
      parse_line(tail, address + mapped_block.size, invocation + 1, [
        mapped_block,
        ..acc
      ])
    }
  }
}
