import gleam/option
import gleam/result
import stack.{type Stack,get_last}
import line_type.{type LineType,get_line_type,Element,Attribute,Empty,Text,TextStart,apply_check_indent}
import gleam/list
import gleam/string
import gleam/io
import argv
import simplifile

fn remove_last(list: List(value)) -> List(value) {
  case list.reverse(list) {
    [] -> []
    [_, ..first] -> list.reverse(first)
  }
}

fn to_element_tag(line: String) -> String {
  line |> string.trim() |> string.drop_left(3)
}

fn get_indent(line: String) -> Int {
  string.length(line) - string.length(string.trim_left(line))
}

fn handle_attribute(line: String) -> String {
  let assert Ok(#(key, value)) = line |> string.trim() |> string.split_once(" ")
  " " <> key <> "=" <> "\"" <> value <> "\"" <> " "
}

fn close_element(el_name) -> String {
    // add self closing in future <ex />
   "</" <> el_name <> ">"
}

fn end_elements(elements_to_end: option.Option(List(String)), output: String) -> String {
  case elements_to_end {
    option.Some([head, ..rest]) -> {
      let output = output <> close_element(head)
      output <> end_elements(option.Some(rest), output)
    }
     option.Some([]) -> {
      ""
    }
    option.None -> {
      ""
    }
  }
}

fn put_attr_inside_tag(output: String, attr_str: String) -> String {
  let output_list = string.split(output, "")
  case list.reverse(output_list) {
    [] -> ""
    [_, ..first] -> {
      first |> list.reverse()
            |> string.join("")
            |> string.append(attr_str <> ">")
    }
  }
}


fn pop_stack(output: String, line: String, stack: Stack) -> #(Stack, String){
    let #(el_name, _) = get_last(stack)
    let stack = remove_last(stack)
    let output = output <> close_element(el_name)
    // recursively remove last stack elements if out of scope
    case stack {
      [] -> #(stack, output)
      _ -> handle_line_stack(output, line, stack)
    }
}

/// if element ends option returned will have the element name
fn handle_line_stack(output: String, line: String, stack: Stack ) -> #(Stack, String) {
      // if this is new element we add it to the stack else we pop it .
      // check if it's new using indent value
      let line_indent = get_indent(line)
      let #(_, prev_indent) = get_last(stack)

      case line_indent > prev_indent {
        True -> {
          let _ = case get_line_type(line) {
            Element -> {
              let stack = list.append(stack, [#(to_element_tag(line), line_indent)])
              #(stack, output)
            }
            _ -> #(stack, output)
          }
        }

        False -> {
          let _ = case get_line_type(line) {
            TextStart -> {
              pop_stack(output, line, stack)
            }
            Element -> {
              let #(stack, output) = pop_stack(output, line, stack)

              // in case last line is an element
              let stack = case stack {
                [] ->{ 
                  list.append(stack, [#(to_element_tag(line), line_indent)])
                }
                _ -> stack
              }
              
              #(stack, output)
            }
            _ -> {
              panic as "Indentation error"
            }
          }
        }
      }
}


fn handle_line(output: String, line: String, stack: Stack) -> #(Stack, String) {
  // let res = ""

  let #(stack, output) = handle_line_stack(output, line, stack)

  case get_line_type(line) {
    Element -> {
      let output = output <> "<" <> to_element_tag(line) <> ">"
      #(stack, output)
    }
    Attribute -> {
      let attr_str = handle_attribute(line)
      #(stack, put_attr_inside_tag(output, attr_str))
    }
    TextStart -> {
      //stack |> update_last(in_attrs: False)
      #(stack, output)
    }
    Text -> {
      #(stack, output)
    }
    Empty -> {
      #(stack, output)
    }
  }

}

fn emit(vxml_lines: List(String), stack: Stack, output: String) -> String {
    //let lines = string.split(vxml, "\n")
    case vxml_lines {
      [] -> output
      [last] -> {
        let #(stack, output) = handle_line(output, last, stack)
        // for last line we check stack in case it's not empty
        let #(_, output) = handle_line_stack(output, last, stack)
        output
      }
      [head, ..rest] -> {
        let #(stack, output) = handle_line(output, head, stack)
        emit(rest, stack, output)
      }
    }
}

pub fn emit_vxml(path: String){
  let stack: Stack = list.new()

  let assert Ok(file_content) = simplifile.read(from: path) 
  file_content 
    |> string.split("\n")
    |> emit(stack, "")
}

pub fn main() {
  io.println("Hello from vxml_emitter!")
  
let args = argv.load().arguments
  case args {
    [path] -> {
        emit_vxml(path) |>   io.print()
      }
    _ -> io.println("Please specify file vxml file")
  }

}
