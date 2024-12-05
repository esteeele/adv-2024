import gleam/int
import gleam/list
import gleam/string

pub fn string_list_to_ints(s: String, split_on: String) {
  string.split(s, split_on)
  |> list.map(fn(val) {
    let assert Ok(i_val) = int.parse(val)
    i_val
  })
}
