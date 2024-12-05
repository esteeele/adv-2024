import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/result
import gleam/string
import simplifile
import utils

pub fn day_2() {
  let assert Ok(contents) = simplifile.read("data/input.txt")

  let #(orderings, puzzle_input) =
    string.split(contents, "\n")
    |> list.split_while(fn(line) { !string.is_empty(line) })

  let lookup_table =
    list.fold(orderings, dict.from_list([#(-1, #([], []))]), fn(acc, line) {
      let mappings = string.split(line, "|")
      case mappings {
        [] -> acc
        [head, tail] -> {
          let assert Ok(i_head) = int.parse(head)
          let assert Ok(i_tail) = int.parse(tail)
          let existing_mappings = dict.get(acc, i_head)
          let upd_acc = case existing_mappings {
            Ok(#(befores, afters)) ->
              dict.insert(acc, i_head, #(befores, [i_tail, ..afters]))
            _ -> dict.insert(acc, i_head, #([], [i_tail]))
          }

          let existing_inverse_mapping = dict.get(upd_acc, i_tail)
          case existing_inverse_mapping {
            Ok(#(befores, afters)) ->
              dict.insert(upd_acc, i_tail, #([i_head, ..befores], afters))
            _ -> dict.insert(upd_acc, i_tail, #([i_head], []))
          }
        }
        _ -> acc
      }
    })

  let res =
    puzzle_input
    |> list.filter(fn(line) { !string.is_empty(line) })
    |> list.map(fn(line) { utils.string_list_to_ints(line, ",") })
    |> list.filter(fn(line) { is_row_valid([], line, lookup_table) })

  let invalid_rows =
    puzzle_input
    |> list.filter(fn(line) { !string.is_empty(line) })
    |> list.map(fn(line) { utils.string_list_to_ints(line, ",") })
    |> list.filter(fn(line) { !is_row_valid([], line, lookup_table) })
    |> list.map(fn(line) {
      list.sort(line, fn(a, b) { compare_to(a, b, lookup_table) })
    })

  let middles = calc_middles(invalid_rows)

  io.debug(middles)
}

fn calc_middles(rows: List(List(Int))) -> Int {
  rows
  |> list.map(fn(line) {
    let #(_, lst) = list.split(line, list.length(line) / 2)
    list.first(lst) |> result.unwrap(-1)
  })
  |> list.fold(0, int.add)
}

fn is_row_valid(
  row_head: List(Int),
  row_tail: List(Int),
  lookup_table: dict.Dict(Int, #(List(Int), List(Int))),
) -> Bool {
  case row_tail {
    [] -> True
    [head, ..tail] -> {
      let #(befores, afters) =
        dict.get(lookup_table, head) |> result.unwrap(#([], []))
      let before_invalid = intersection(afters, row_head)
      let after_invalid = intersection(befores, tail)
      let is_invalid =
        bool.or(!list.is_empty(before_invalid), !list.is_empty(after_invalid))
      case is_invalid {
        True -> False
        False -> is_row_valid([head, ..row_head], tail, lookup_table)
      }
    }
  }
}

fn compare_to(
  a: Int,
  b: Int,
  lookup_table: dict.Dict(Int, #(List(Int), List(Int))),
) -> order.Order {
  let #(befores, afters) = dict.get(lookup_table, a) |> result.unwrap(#([], []))
  case list.contains(afters, b) {
    True -> order.Gt
    False -> {
      case list.contains(befores, b) {
        True -> order.Lt
        False -> order.Eq
      }
    }
  }
}

fn intersection(a: List(Int), b: List(Int)) {
  let filtered_a = list.filter(a, fn(num) { list.contains(b, num) })
  let filtered_b = list.filter(b, fn(num) { list.contains(a, num) })
  list.append(filtered_a, filtered_b)
}
