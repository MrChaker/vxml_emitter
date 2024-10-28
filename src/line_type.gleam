import gleam/string

pub type LineType {
  Element
  Attribute
  TextStart
  Text
  Empty
}

pub fn get_line_type(line: String) -> LineType {
 // let line_chars_list = line |> string.starts_with("<>") && line |> string.ends_with("<>")
  let line_chars_list = line |> string.trim() |> string.split("")
  case line_chars_list {
    [] -> Empty
    ["<", ">"] -> TextStart
    ["<", ">", ..] -> Element
    ["\"", ..] -> Text
    [_, _, ..] -> Attribute
    [_] -> Attribute
  } 
}

pub fn apply_check_indent(line: String) -> Bool {
  get_line_type(line) == Element || get_line_type(line) == TextStart
}