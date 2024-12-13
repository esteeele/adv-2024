import gleam/dict
import gleam/int
import gleam/list
import gleam/string
import simplifile

pub fn string_list_to_ints(s: String, split_on: String) {
  string.split(s, split_on)
  |> list.filter(fn(s) { !string.is_empty(s) })
  |> list.map(fn(val) {
    let assert Ok(i_val) = int.parse(val)
    i_val
  })
}

pub fn open_input() -> List(String) {
  let assert Ok(contents) = simplifile.read("data/input.txt")
  string.split(contents, "\n")
}

pub fn build_int_lookup_list(l: List(#(Int, Int))) -> dict.Dict(Int, List(Int)) {
  list.fold(l, dict.from_list([]), add_to_dict)
}

pub fn add_to_dict(acc: dict.Dict(Int, List(Int)), pair: #(Int, Int)) {
  let #(left, right) = pair
  let existing_list = dict.get(acc, left)
  case existing_list {
    Ok(tail) -> dict.insert(acc, left, [right, ..tail])
    _ -> dict.insert(acc, left, [right])
  }
}

pub fn increment_frequency(acc: dict.Dict(a, Int), a, by: Int) {
  let existing_frequency = dict.get(acc, a)
  case existing_frequency {
    Ok(current) -> dict.insert(acc, a, current + by)
    _ -> dict.insert(acc, a, by)
  }
}

pub fn map_index_to_coords(i, row_size) {
  let x = i % row_size
  let y = i / row_size
  #(x, y)
}

pub fn to_frequencies(input: List(a)) {
  list.group(input, fn(value) { value })
  |> dict.map_values(fn(_, v) { list.length(v) })
}
