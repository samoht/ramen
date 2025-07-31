open Html

let mk_id = function None -> [] | Some i -> [ At.id i ]

let h1' ?color ?clamp ?padding ?id ~palette node =
  let color_class =
    match color with
    | None | Some `Normal -> Colors.text_primary palette
    | Some `Light -> Tw.(text white)
  in
  let padding =
    match padding with
    | None | Some `Normal -> Tw.(pb (int 12))
    | Some `Small -> Tw.(pb (int 8))
  in
  let id_attrs = mk_id id in
  let offset =
    match id with
    | None -> []
    | Some _ -> [ Tw.(pt (int 56)); Tw.(neg_mt (int 56)) ]
  in
  let clamp_classes =
    match clamp with
    | None -> []
    | Some n when n > 0 && n <= 6 -> [ Tw.line_clamp n ]
    | Some _ -> []
  in
  h1 ~at:id_attrs
    ~tw:
      ([
         Tw.text_4xl;
         Tw.font_bold;
         Tw.tracking_tight;
         Tw.on_sm [ Tw.text_5xl ];
         padding;
         color_class;
       ]
      @ offset @ clamp_classes)
    node

let h2' ?color ?clamp ?padding ?id ~palette node =
  let color_class =
    match color with
    | None | Some `Normal -> Colors.text_primary palette
    | Some `Light -> Tw.(text white)
  in
  let padding =
    match padding with
    | None | Some `Normal -> Tw.(pb (int 8))
    | Some `Small -> Tw.(pb (int 4))
  in
  let id_attrs = mk_id id in
  let offset =
    match id with
    | None -> []
    | Some _ -> [ Tw.(pt (int 56)); Tw.(neg_mt (int 56)) ]
  in
  let clamp_classes =
    match clamp with
    | None -> []
    | Some n when n > 0 && n <= 6 -> [ Tw.line_clamp n ]
    | Some _ -> []
  in
  h2 ~at:id_attrs
    ~tw:
      ([
         Tw.text_3xl;
         Tw.font_bold;
         Tw.tracking_tight;
         Tw.on_sm [ Tw.text_4xl ];
         padding;
         color_class;
       ]
      @ offset @ clamp_classes)
    node

let h3' ?color ?clamp ?padding ?id ~palette node =
  let color_class =
    match color with
    | None | Some `Normal -> Colors.text_primary palette
    | Some `Light -> Tw.(text white)
  in
  let padding =
    match padding with
    | None | Some `Normal -> Tw.(pb (int 4))
    | Some `Small -> Tw.(pb (int 2))
  in
  let id_attrs = mk_id id in
  let offset =
    match id with
    | None -> []
    | Some _ -> [ Tw.(pt (int 56)); Tw.(neg_mt (int 56)) ]
  in
  let clamp_classes =
    match clamp with
    | None -> []
    | Some n when n > 0 && n <= 6 -> [ Tw.line_clamp n ]
    | Some _ -> []
  in
  h3 ~at:id_attrs
    ~tw:
      ([
         Tw.text_xl;
         Tw.font_bold;
         Tw.tracking_tight;
         Tw.on_sm [ Tw.text_2xl ];
         padding;
         color_class;
       ]
      @ offset @ clamp_classes)
    node

let h4' ?color ?clamp ?padding ?id ~palette node =
  let color_class =
    match color with
    | None | Some `Normal -> Colors.text_primary palette
    | Some `Light -> Tw.(text white)
  in
  let padding =
    match padding with
    | None | Some `Normal -> Tw.(pb (int 4))
    | Some `Small -> Tw.(pb (int 2))
  in
  let id_attrs = mk_id id in
  let offset =
    match id with
    | None -> []
    | Some _ -> [ Tw.(pt (int 56)); Tw.(neg_mt (int 56)) ]
  in
  let clamp_classes =
    match clamp with
    | None -> []
    | Some n when n > 0 && n <= 6 -> [ Tw.line_clamp n ]
    | Some _ -> []
  in
  h4 ~at:id_attrs
    ~tw:
      ([ Tw.text_lg; Tw.font_bold; Tw.tracking_tight; padding; color_class ]
      @ offset @ clamp_classes)
    node

let h1 ?color ?clamp ?padding ?id ~palette str =
  h1' ?color ?clamp ?padding ?id ~palette [ txt str ]

let h2 ?color ?clamp ?padding ?id ~palette str =
  h2' ?color ?clamp ?padding ?id ~palette [ txt str ]

let h3 ?color ?clamp ?padding ?id ~palette str =
  h3' ?color ?clamp ?padding ?id ~palette [ txt str ]

let h4 ?color ?clamp ?padding ?id ~palette str =
  h4' ?color ?clamp ?padding ?id ~palette [ txt str ]
