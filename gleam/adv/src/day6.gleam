import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/result
import gleam/set
import gleam/string
import utils

pub type Direction {
  Up
  Down
  Right
  Left
}

pub type Pieces {
  Block(x: Int, y: Int)
  Guard(x: Int, y: Int, direction: Direction)
}

pub fn solve() {
  let input = utils.open_input()
  let blocks =
    list.index_fold(input, [], fn(acc, item, column_index) {
      let row_blocks =
        string.to_graphemes(item)
        |> list.index_fold([], fn(row_acc, row_item, row_index) {
          case row_item {
            "#" -> [Block(row_index, column_index), ..row_acc]
            "^" -> [Guard(row_index, column_index, Up), ..row_acc]
            _ -> row_acc
          }
        })
      list.append(acc, row_blocks)
    })
    |> list.group(fn(piece) {
      case piece {
        Guard(_, _, _) -> "guard"
        _ -> "block"
      }
    })

  let just_blocks = dict.get(blocks, "block") |> result.unwrap([])
  let x_lookup =
    list.map(just_blocks, fn(piece) { #(piece.x, piece.y) })
    |> utils.build_int_lookup_list
  let y_lookup =
    list.map(just_blocks, fn(piece) { #(piece.y, piece.x) })
    |> utils.build_int_lookup_list
  let assert Ok(Guard(x, y, direction)) =
    dict.get(blocks, "guard") |> result.unwrap([]) |> list.first

  // hardcoded the lines don't add me
  let board_size = 130
  let visited_nodes =
    play_game(
      just_blocks,
      x_lookup,
      y_lookup,
      #(x, y, direction),
      set.from_list([]),
      set.from_list([]),
      board_size - 1,
      board_size - 1,
    )
    |> result.unwrap(set.from_list([]))

  let part_2 =
    list.map(list.range(0, board_size * board_size), fn(i) {
      let x_pos = i % board_size
      let y_pos = i / board_size
      #(x_pos, y_pos)
    })
    |> list.filter(fn(pair) {
      // only check nodes actually walked in the 'normal' route
      let #(x_pos, y_pos) = pair
      set.contains(visited_nodes, #(x_pos, y_pos))
    })
    |> list.filter(fn(pair) {
      let #(x_pos, y_pos) = pair

      let invalid_position =
        list.any(just_blocks, fn(block) {
          bool.and(block.x == x_pos, block.y == y_pos)
        })
      let inc_guard =
        bool.or(invalid_position, bool.and(x == x_pos, y == x_pos))

      case inc_guard {
        True -> False
        False -> {
          let visited_nodes =
            play_game(
              just_blocks,
              utils.add_to_dict(x_lookup, #(x_pos, y_pos)),
              utils.add_to_dict(y_lookup, #(y_pos, x_pos)),
              #(x, y, direction),
              set.from_list([]),
              set.from_list([]),
              board_size - 1,
              board_size - 1,
            )
          case visited_nodes {
            Ok(_) -> False
            _ -> True
          }
        }
      }
    })
  io.debug(part_2)
  io.debug(part_2 |> list.length)
}

fn play_game(
  blocks: List(Pieces),
  x_lookup: dict.Dict(Int, List(Int)),
  y_lookup: dict.Dict(Int, List(Int)),
  guard: #(Int, Int, Direction),
  acc: set.Set(#(Int, Int)),
  guard_positions: set.Set(#(Int, Int, Direction)),
  number_columns: Int,
  number_rows: Int,
) -> Result(set.Set(#(Int, Int)), Int) {
  let #(x, y, direction) = guard
  case set.contains(guard_positions, #(x, y, direction)) {
    True -> Error(-1)
    False -> {
      let #(blocking_piece, exit_piece, new_direction) = case direction {
        Up -> #(
          dict.get(x_lookup, x)
            |> result.unwrap([])
            |> list.filter(fn(c_y) { c_y < y })
            |> list.sort({ order.reverse(int.compare) })
            |> list.map(fn(val) { Block(x, val) }),
          Block(x, -1),
          Right,
        )
        Down -> #(
          dict.get(x_lookup, x)
            |> result.unwrap([])
            |> list.filter(fn(c_y) { c_y > y })
            |> list.sort({ int.compare })
            |> list.map(fn(val) { Block(x, val) }),
          Block(x, number_columns + 1),
          Left,
        )
        Left -> #(
          dict.get(y_lookup, y)
            |> result.unwrap([])
            |> list.filter(fn(c_x) { c_x < x })
            |> list.sort({ order.reverse(int.compare) })
            |> list.map(fn(val) { Block(val, y) }),
          Block(-1, y),
          Up,
        )
        Right -> #(
          dict.get(y_lookup, y)
            |> result.unwrap([])
            |> list.filter(fn(c_x) { c_x > x })
            |> list.sort({ int.compare })
            |> list.map(fn(val) { Block(val, y) }),
          Block(number_rows + 1, y),
          Down,
        )
      }

      let has_block = list.first(blocking_piece)
      case has_block {
        Ok(blocker) -> {
          let visited_nodes = visit_nodes(Block(x, y), blocker)
          let updated_visited_nodes =
            set.union(set.from_list(visited_nodes), acc)
          let assert Ok(#(new_guard_x, new_guard_y)) = list.first(visited_nodes)
          play_game(
            blocks,
            x_lookup,
            y_lookup,
            #(new_guard_x, new_guard_y, new_direction),
            updated_visited_nodes,
            set.union(guard_positions, set.from_list([#(x, y, direction)])),
            number_columns,
            number_rows,
          )
        }
        _ -> {
          // the end 
          let visited_nodes = visit_nodes(Block(x, y), exit_piece)
          Ok(set.union(set.from_list(visited_nodes), acc))
        }
      }
    }
  }
}

fn visit_nodes(start: Pieces, end: Pieces) -> List(#(Int, Int)) {
  let x_range = list.range(start.x, end.x)
  let y_range = list.range(start.y, end.y)
  list.fold(x_range, [], fn(acc, x) {
    list.fold(y_range, acc, fn(acc, y) { [#(x, y), ..acc] })
  })
  |> list.drop(1)
}
