import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/regex
import gleam/string
import utils

pub fn day12() {
  let input_file =
    utils.open_input() |> list.filter(fn(line) { !string.is_empty(line) })
  let chunked = list.sized_chunk(input_file, 3)
  let assert Ok(re) = regex.from_string("[0-9]+")
  let an_answer =
    list.map(chunked, fn(chunk) {
      let i_hate_string_parsing = string.join(chunk, "|")
      let numbers = regex.scan(with: re, content: i_hate_string_parsing)
      let numbers =
        list.map(numbers, fn(match) { match.content })
        |> list.map(fn(number) {
          let assert Ok(i_val) = int.parse(number)
          i_val
        })
      case numbers {
        [a_x, a_y, b_x, b_y, x_target, y_target] -> {
          let calculation_result =
            im_an_operator_with_my_pocket_calculator(
              a_x,
              b_x,
              x_target + 10_000_000_000_000,
              a_y,
              b_y,
              y_target + 10_000_000_000_000,
            )
          case calculation_result {
            Ok(#(a, b)) -> {
              a * 3 + b
            }
            Error(code) -> code
          }
        }
        _ -> 0
      }
    })
  io.debug(an_answer)
  list.fold(an_answer, 0, fn(acc, x) { acc + x })
}

pub fn im_an_operator_with_my_pocket_calculator(
  a_x_multicand: Int,
  b_x_multicand: Int,
  x_target: Int,
  a_y_multicand: Int,
  b_y_multicand: Int,
  y_target: Int,
) -> Result(#(Int, Int), Int) {
  // rearrange for a in terms of b and subsitute into second expression to find b
  let numerator = a_x_multicand * y_target - x_target * a_y_multicand
  let denominator =
    b_y_multicand * a_x_multicand - b_x_multicand * a_y_multicand
  let has_int_soln =
    bool.and(
      numerator % denominator == 0,
      { x_target - numerator / denominator * b_x_multicand } % a_x_multicand
        == 0,
    )
  case has_int_soln {
    True -> {
      let b = numerator / denominator
      let a = { x_target - b * b_x_multicand } / a_x_multicand
      Ok(#(a, b))
    }
    _ -> Error(0)
  }
}
