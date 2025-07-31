open Html

type variant = Default | Elevated | Outlined

let variant_styles = function
  | Default -> Tw.[ bg white; rounded lg; p (int 6) ]
  | Elevated -> Tw.[ bg white; rounded lg; shadow lg; p (int 6) ]
  | Outlined ->
      Tw.
        [
          bg white;
          border `Default;
          border_color ~shade:200 gray;
          rounded lg;
          p (int 6);
        ]

let render ?(variant = Default) ?(classes = []) children =
  let styles = variant_styles variant @ classes in
  div ~tw:styles children
