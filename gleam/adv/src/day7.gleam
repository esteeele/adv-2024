import gleam/int
import gleam/io
import gleam/list
import gleam/string
import utils

fn combiner(a: Int, b: Int) -> Int {
  let combined_nums = int.to_string(a) <> int.to_string(b)
  let assert Ok(result) = combined_nums |> int.parse
  result
}

pub fn day7() {
  let ok_rows =
    utils.open_input()
    |> list.map(fn(line) {
      let split = string.split(line, ":")
      let assert Ok(target) = list.first(split)
      let assert Ok(i_target) = target |> int.parse()
      let assert Ok(operands) =
        list.drop(split, 1)
        |> list.first
      let i_operands = utils.string_list_to_ints(operands, " ")

      let possible_results = iterate_numbers_2(i_operands, i_target)
      case list.contains(possible_results, i_target) {
        True -> i_target
        False -> 0
      }
    })
    |> list.fold(0, int.add)
}

pub fn iterate_numbers_2(numbers: List(Int), target: Int) -> List(Int) {
  case numbers {
    [] -> []
    [last] -> [last]
    [head, second, ..tail] -> {
      list.map([int.add, int.multiply, combiner], fn(operation) {
        let result = operation(head, second)
        case result > target {
          True -> []
          False -> iterate_numbers_2([result, ..tail], target)
        }
      })
      |> list.flatten
    }
  }
}
