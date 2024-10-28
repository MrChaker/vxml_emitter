import gleam/list
import gleam/io
import gleeunit
import gleeunit/should
import vxml_emitter

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_test() {
  // let stack = []
  // let stack = list.append(stack, [10])
  // io.debug(stack)

  vxml_emitter.emit_vxml("./test/test.vxml")
    |> io.debug()
  "0" |> should.equal("0")
}
