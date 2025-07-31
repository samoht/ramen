open Html
open Tw

(* Helper function to determine background styles *)
let background_style = function
  | `White -> [ Tw.bg Tw.white ]
  | `Gray -> [ Tw.bg ~shade:50 Tw.gray ]
  | `Dark -> [ Tw.bg ~shade:900 Tw.gray ]
  | `Blue -> [ Tw.bg ~shade:50 Tw.blue ]
  | `Gradient -> [] (* Will use raw class for gradient *)

(* Helper function to determine width style *)
let width_style = function
  | `Normal -> [ Tw.max_w (Tw.rem 64.0) ] (* 5xl = 64rem *)
  | `Large -> [ Tw.max_w (Tw.rem 80.0) ]
(* 7xl = 80rem *)

(* Helper function to determine padding styles *)
let padding_style py pt pb =
  match (py, pt, pb) with
  | `None, _, _ -> [ Tw.py (Tw.int 0) ]
  | `Small, _, _ -> [ Tw.py (Tw.int 8) ]
  | `Normal, `Normal, `Normal -> [ Tw.py (Tw.int 24) ]
  | `Normal, `Small, `Normal -> [ Tw.pt (Tw.int 8); Tw.pb (Tw.int 24) ]
  | `Normal, `None, `Normal -> [ Tw.pt (Tw.int 0); Tw.pb (Tw.int 24) ]
  | `Normal, `Normal, `Small -> [ Tw.pt (Tw.int 24); Tw.pb (Tw.int 8) ]
  | `Normal, `Normal, `None -> [ Tw.pt (Tw.int 24); Tw.pb (Tw.int 0) ]
  | `Normal, `Small, `Small -> [ Tw.py (Tw.int 8) ]
  | `Normal, `Small, `None -> [ Tw.pt (Tw.int 8); Tw.pb (Tw.int 0) ]
  | `Normal, `None, `Small -> [ Tw.pt (Tw.int 0); Tw.pb (Tw.int 8) ]
  | `Normal, `None, `None -> [ Tw.py (Tw.int 0) ]

(* Helper function to render dark background overlay *)
let render_dark_background () =
  [
    (* Simple dark overlay instead of complex gradient *)
    div
      ~tw:
        [
          Tw.absolute;
          Tw.inset_0;
          Tw.bg ~shade:900 Tw.black;
          Tw.opacity 10;
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
    | `Gradient -> [ border_t; border_color ~shade:200 gray ]
    | _ -> []
  in
  section
    ~tw:
      (bg_styles @ padding_styles @ gradient_styles
      @ [ relative; overflow_hidden; overflow_auto ])
    ~at:id
    [
      div
        ~tw:(width_styles @ [ mx auto; w full; px (int 4) ])
        (background_elems @ description);
    ]
