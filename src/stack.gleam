import gleam/result
import gleam/list

type ElementName = String
type Indent = Int

pub type StackEl = #(ElementName, Indent)

pub type Stack = List(#(ElementName, Indent))

pub fn get_last(stack: Stack) -> StackEl {
  let last = list.last(stack)
  last |> result.unwrap(#("", -1))
}

// pub fn update_last(stack: Stack){
//    case list.reverse(stack) {
//     [last, ..first] -> {
//       let #(last_el_name, last_indent) = last
//       first |> list.reverse()
//             |> list.append([#(last_el_name, last_indent)])
//     }
//     _ -> list.reverse(stack)
//    }
// }