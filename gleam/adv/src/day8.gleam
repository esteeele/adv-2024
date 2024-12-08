import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/set
import gleam/string
import simplifile
import utils

pub type Point {
  Point(x: Int, y: Int, ref: String)
}

fn antinode(a, b) {
  Point(a, b, "#")
}

pub fn day8() {
  let contents = utils.open_input()
  let assert Ok(first_row) = list.first(contents)
  let board_size = string.length(first_row)

  let flat_grid = string.concat(contents) |> string.to_graphemes()

  let antennas =
    list.index_fold(flat_grid, [], fn(acc, value, index) {
      case value {
        "." -> acc
        antenna -> {
          let #(x, y) = utils.map_index_to_coords(index, board_size)
          [Point(x, y, antenna), ..acc]
        }
      }
    })
  // ordering of p1,p2 shouldn't be important
  let grouped_antennas = list.group(antennas, fn(p: Point) { p.ref })
  let antinodes =
    dict.fold(grouped_antennas, [], fn(acc, key, value) {
      let pairs = gen_line_pairs([], value)
      let antinodes =
        list.map(pairs, fn(pair) {
          let #(p1, p2) = pair
          gen_antinodes(p1, p2)
        })
        |> list.map(fn(pair) {
          let #(p1, p2) = pair
          list.filter([p1, p2], fn(point) { point_in_bounds(point, board_size) })
        })
        |> list.flatten
      list.append(acc, antinodes)
      // for each antenna find all lines linking them
    })
    |> set.from_list

  io.println("Number unique antinodes: " <> int.to_string(set.size(antinodes)))
  print_board(list.append(antennas, set.to_list(antinodes)), board_size)

  let antinodes_p2 =
    dict.fold(grouped_antennas, [], fn(acc, key, value) {
      let pairs = gen_line_pairs([], value)
      list.map(pairs, fn(pair) {
        let #(p1, p2) = pair
        gen_antinodes_rec_forward(p1, p2, board_size)
      })
      |> list.append(acc)
    })
    |> list.flatten
    |> set.from_list
  io.println("")
  print_board(list.append(antennas, set.to_list(antinodes_p2)), board_size)
  io.debug(set.size(antinodes_p2))
}

fn print_board(points: List(Point), board_size) {
  let board =
    list.map(list.range(0, board_size - 1), fn(y_index) {
      list.map(list.range(0, board_size - 1), fn(index) {
        let points_for_row =
          list.filter(points, fn(point) { point.y == y_index })
          |> list.sort(fn(p1, p2) { int.compare(p1.x, p2.x) })
        case list.find(points_for_row, fn(point) { point.x == index }) {
          Ok(p) -> p.ref
          _ -> "."
        }
      })
      |> string.concat
    })
    |> string.join("\n")
  io.println(board)
}

pub fn gen_line_pairs(acc, lst) {
  case lst {
    [] -> acc
    [_] -> acc
    [head, ..tail] -> {
      let pairs = list.map(tail, fn(t_num) { #(head, t_num) })
      gen_line_pairs(list.append(acc, pairs), tail)
    }
  }
}

pub fn gen_antinodes(a: Point, b: Point) -> #(Point, Point) {
  let dx = b.x - a.x
  let dy = b.y - a.y

  #(antinode(b.x + dx, b.y + dy), antinode(a.x - dx, a.y - dy))
}

pub fn gen_antinodes_rec_forward(a: Point, b: Point, board_size) -> List(Point) {
  // to make this cleverer should have known the magnitude of the gradient and used that to guide the expansion 
  let dx = b.x - a.x
  let dy = b.y - a.y

  //this is extremely wasteful but it works :)
  let num_steps = board_size / int.max(dx, dy)
  list.range(0, num_steps)
  |> list.map(fn(step) {
    let a1 = antinode(b.x + step * dx, b.y + dy * step)
    let a2 = antinode(a.x - dx * step, a.y - dy * step)
    [a1, a2]
  })
  |> list.flatten
  |> list.filter(fn(point) { point_in_bounds(point, board_size) })
}

fn point_in_bounds(a: Point, board_size: Int) -> Bool {
  let x_ok = bool.and(a.x >= 0, a.x < board_size)
  let y_ok = bool.and(a.y >= 0, a.y < board_size)
  bool.and(x_ok, y_ok)
}
