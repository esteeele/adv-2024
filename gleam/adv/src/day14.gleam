import gleam/dict
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/regex
import gleam/result
import gleam/string
import simplifile
import utils

pub fn part_2() {
  let max_range = list.range(1, 101 * 103)
  let orderly_ones =
    list.map(max_range, fn(iteration) {
      let grid = build_grid(iteration)
      let orderliness = find_orderliness(grid)
      #(orderliness, dict.values(grid) |> list.flatten(), iteration)
    })
    |> list.filter(fn(order) {
      let #(or, _, _) = order
      or >. 0.7
    })
    |> list.map(with: fn(pair) {
      let #(_, list, iteration) = pair
      io.debug(list)
      int.to_string(iteration) <> "\n" <> utils.print_board(list, 103) <> "\n"
    })
    |> string.join("\n")

  simplifile.write(to: "christmas.txt", contents: orderly_ones)
}

pub fn find_orderliness(points: dict.Dict(String, List(#(Int, Int)))) {
  dict.fold(points, 0.0, fn(acc, _, val) {
    // find number of points in a straight line per quadrant
    let assert Ok(max_row_size) =
      list.group(val, fn(point) {
        let #(x, _) = point
        x
      })
      |> dict.values()
      |> list.sort(by: fn(a, b) {
        order.negate(int.compare(list.length(a), list.length(b)))
      })
      |> list.map(list.length)
      |> list.first()
    let assert Ok(lined_up_degree) =
      float.divide(int.to_float(max_row_size), int.to_float(list.length(val)))
    acc +. lined_up_degree
  })
}

pub fn build_grid(num_steps: Int) {
  let width = 101
  let height = 103
  let res =
    utils.open_input()
    |> list.map(fn(line) { parse_line(line) })
    |> list.map(fn(point_and_vector) {
      case point_and_vector {
        Ok([#(p_x, p_y), #(v_x, v_y)]) ->
          Ok(move_robot(#(p_x, p_y), v_x, v_y, num_steps, width, height))
        _ -> Error(-1)
      }
    })
    |> list.filter(fn(numbers) { result.is_ok(numbers) })

  list.group(res, fn(point) {
    case point {
      Ok(#(x, y)) -> {
        let half_width = width / 2
        let half_height = height / 2
        let comparison_x = int.compare(x, half_width)
        let quad_x = case comparison_x {
          order.Eq -> "ignore"
          order.Gt -> "right"
          order.Lt -> "left"
        }
        let comparison_y = int.compare(y, half_height)
        let quad_y = case comparison_y {
          order.Eq -> "ignore"
          order.Gt -> "top"
          order.Lt -> "bottom"
        }
        quad_x <> "_" <> quad_y
      }
      _ -> "ignore"
    }
  })
  |> dict.filter(fn(k, _) { !string.contains(k, "ignore") })
  |> dict.map_values(fn(_, values) {
    list.map(values, fn(value) { result.unwrap(value, #(-1, -1)) })
  })
}

pub fn parse_line(line: String) {
  let assert Ok(re) = regex.from_string("[-]?[0-9]+")
  let numbers = regex.scan(with: re, content: line)
  let numbers =
    list.map(numbers, fn(match) { match.content })
    |> list.map(fn(number) {
      let assert Ok(i_val) = int.parse(number)
      i_val
    })
  case numbers {
    [x, y, v_x, v_y] -> Ok([#(x, y), #(v_x, v_y)])
    _ -> Error(-1)
  }
}

pub fn move_robot(
  point: #(Int, Int),
  x_move: Int,
  y_move: Int,
  number_steps: Int,
  width: Int,
  height: Int,
) {
  let #(point_x, point_y) = point
  let final_x = point_x + x_move * number_steps
  let final_y = point_y + y_move * number_steps
  let rel_x = map_point(final_x, x_move > 0, width)
  let rel_y = map_point(final_y, y_move > 0, height)
  #(rel_x, rel_y)
}

fn map_point(final_value: Int, positive_magnitude: Bool, dimension: Int) {
  case positive_magnitude {
    True -> final_value % dimension
    False -> {
      let mod = final_value % dimension
      case mod == 0 {
        True -> 0
        False -> dimension + mod
      }
    }
  }
}
