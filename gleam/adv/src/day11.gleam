import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile
import utils

pub fn day_11() {
  let assert Ok(input_line) = simplifile.read("data/input.txt")
  let stones =
    utils.string_list_to_ints(input_line, " ")
    |> utils.to_frequencies()
  let range = list.range(1, 75)
  let post_blinks =
    list.fold(range, stones, fn(acc, iteration) {
      io.debug(iteration)
      dict.fold(acc, dict.from_list([]), fn(step_acc, key, value) {
        let mapped_values = run_process(key)
        list.fold(mapped_values, step_acc, fn(step_acc, new_stone) {
          utils.increment_frequency(step_acc, new_stone, value)
        })
      })
    })
  io.debug(post_blinks)
  let lst_size = dict.fold(post_blinks, 0, fn(acc, _, v) { acc + v })
  io.debug(lst_size)
}

fn run_process(value: Int) -> List(Int) {
  let digits: String = int.to_string(value)
  let head_digits = string.length(digits)

  case head_digits % 2 {
    0 -> {
      let pair =
        string.drop_end(digits, head_digits / 2)
        <> " "
        <> string.drop_start(digits, head_digits / 2)
      utils.string_list_to_ints(pair, " ")
    }
    _ -> {
      case value {
        0 -> [1]
        _ -> [value * 2024]
      }
    }
  }
}
