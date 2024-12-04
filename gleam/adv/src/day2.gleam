import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import simplifile

pub fn day_2() {
  let assert Ok(contents) = simplifile.read("data/input.txt")

  let split_file = string.split(contents, "\n")
  let stuff =
    list.filter(split_file, fn(s) {
      let values =
        string.split(s, " ")
        |> list.map(fn(val) {
          let assert Ok(i_val) = int.parse(val)
          i_val
        })
      // generate all lists each missing one value (do not be smart ... never be smart)
      let all_possible_lists =
        generate_all_lists_missing_one([], values, [values])
      list.any(all_possible_lists, fn(lst) { check_line(lst, option.None) })
    })
  io.println(
    "There are " <> int.to_string(list.length(stuff)) <> " matching levels",
  )
}

fn generate_all_lists_missing_one(
  head: List(Int),
  tail: List(Int),
  all_lists: List(List(Int)),
) -> List(List(Int)) {
  case tail {
    [] -> all_lists
    [head_of_tail, ..tail] -> {
      // head_of_tail is being excluded
      let reduced_list = list.append(head, tail)

      generate_all_lists_missing_one(list.append(head, [head_of_tail]), tail, [
        reduced_list,
        ..all_lists
      ])
    }
  }
}

fn check_line(
  level: List(Int),
  arg: option.Option(fn(Int, Int) -> Bool),
) -> Bool {
  case level {
    [_] -> True
    [head, ..tail] -> {
      let second = list.first(tail) |> result.unwrap(head)
      let diff = head - second
      let eval_fun =
        option.unwrap(arg, case diff {
          i if i > 0 -> fn(arg1: Int, arg2: Int) { arg1 > arg2 }
          i if i < 0 -> fn(arg1: Int, arg2: Int) { arg1 < arg2 }
          _ -> fn(_: Int, _: Int) { False }
        })
      let same_order_check = eval_fun(head, second)
      let abs_diff = int.absolute_value(head - second)
      let abs_diff_safe = bool.and(abs_diff <= 3, abs_diff >= 1)
      let is_line_valid = bool.and(same_order_check, abs_diff_safe)

      case is_line_valid {
        True -> check_line(tail, option.Some(eval_fun))
        False -> False
      }
    }
    [] -> True
  }
}
