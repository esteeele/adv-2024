import day14
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn point_mapping_test() {
  let point = #(2, 4)

  let res = day14.move_robot(point, 2, -3, 5, 11, 7)
  should.equal(res, #(1, 3))
}
