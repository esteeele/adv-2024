import gleam/dict
import gleam/list
import gleam/string
import utils

pub fn find_trails() {
  let contents =
    utils.open_input()
    |> list.map(fn(line) { utils.string_list_to_ints(line, "") })
  let assert Ok(first_line) = contents |> list.first()
  let board_size = list.length(first_line)
  let contents = contents |> list.flatten()

  let lookup_list =
    list.index_fold(contents, dict.from_list([]), fn(acc, num, index) {
      dict.insert(acc, index, num)
    })
  dict.filter(lookup_list, fn(k, v) { todo })
}
