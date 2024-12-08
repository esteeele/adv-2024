import day8
import gleam/int
import gleam/io
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn gen_antinodes_test() {
  let point1 = day8.Point(5, 4, "a")
  let point2 = day8.Point(7, 5, "a")
  let #(antinode1, antinode2) = day8.gen_antinodes(point1, point2)

  io.debug(antinode1)
  should.equal(antinode1, day8.Point(9, 6, "#"))
  should.equal(antinode2, day8.Point(3, 3, "#"))
}

pub fn gen_antinodes_test_p2() {
  let point1 = day8.Point(5, 4, "a")
  let point2 = day8.Point(7, 5, "a")
  let results = day8.gen_all_antinodes(point1, point2, 12)

  should.equal(results, [day8.Point(9, 6, "a"), day8.Point(11, 7, "a")])
}
