open Html

(* Helper function to determine background styles *)
let background_style = function
  | `White -> [ Tw.bg_white ]
  | `Gray -> [ Tw.bg ~shade:50 Tw.Gray ]
  | `Dark -> [ Tw.bg ~shade:900 Tw.Gray ]
  | `Blue -> [ Tw.bg ~shade:50 Tw.Blue ]
  | `Gradient -> [] (* Will use raw class for gradient *)

(* Helper function to determine width style *)
let width_style = function
  | `Normal -> [ Tw.max_w_5xl ]
  | `Large -> [ Tw.max_w_7xl ]

(* Helper function to determine padding styles *)
let padding_style py pt pb =
  match (py, pt, pb) with
  | `None, _, _ -> [ Tw.py (Int 0) ]
  | `Small, _, _ -> [ Tw.py (Int 8) ]
  | `Normal, `Normal, `Normal -> [ Tw.py (Int 24) ]
  | `Normal, `Small, `Normal -> [ Tw.pt (Int 8); Tw.pb (Int 24) ]
  | `Normal, `None, `Normal -> [ Tw.pt (Int 0); Tw.pb (Int 24) ]
  | `Normal, `Normal, `Small -> [ Tw.pt (Int 24); Tw.pb (Int 8) ]
  | `Normal, `Normal, `None -> [ Tw.pt (Int 24); Tw.pb (Int 0) ]
  | `Normal, `Small, `Small -> [ Tw.py (Int 8) ]
  | `Normal, `Small, `None -> [ Tw.pt (Int 8); Tw.pb (Int 0) ]
  | `Normal, `None, `Small -> [ Tw.pt (Int 0); Tw.pb (Int 8) ]
  | `Normal, `None, `None -> [ Tw.py (Int 0) ]

(* Helper function to render dark background overlay *)
let render_dark_background () =
  [
    (* Simple dark overlay instead of complex gradient *)
    div
      ~tw:
        [
          Tw.absolute;
          Tw.inset_0;
          Tw.bg ~shade:900 Tw.Black;
          Tw.opacity_10;
          Tw.pointer_events_none;
        ]
      [];
  ]

let render ?(width = `Normal) ?(background = `White) ?(py = `Normal)
    ?(pt = `Normal) ?(pb = `Normal) ?id description =
  let bg_styles = background_style background in
  let width_styles = width_style width in
  let padding_styles = padding_style py pt pb in
  let background_elems =
    match background with `Dark -> render_dark_background () | _ -> []
  in
  let id = match id with None -> [] | Some x -> [ At.id x ] in
  let gradient_styles =
    match background with
    | `Gradient -> [ Tw.border_t; Tw.border_gray_200 ]
    | _ -> []
  in
  section
    ~tw:
      (bg_styles @ padding_styles @ gradient_styles
      @ [ Tw.relative; Tw.overflow_hidden; Tw.overflow_auto ])
    ~at:id
    [
      div
        ~tw:(width_styles @ [ Tw.mx Auto; Tw.w_full; Tw.px (Int 4) ])
        (background_elems @ description);
    ]
