open Html

type variant = Default | Elevated | Outlined

let variant_styles = function
  | Default -> Tw.[ bg_white; rounded Lg; p (Int 6) ]
  | Elevated -> Tw.[ bg_white; rounded Lg; shadow Lg; p (Int 6) ]
  | Outlined ->
      Tw.
        [
          bg_white; border; border_color ~shade:200 Gray; rounded Lg; p (Int 6);
        ]

let render ?(variant = Default) ?(classes = []) children =
  let styles = variant_styles variant @ classes in
  div ~tw:styles children
