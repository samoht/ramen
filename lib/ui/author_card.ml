open Core
open Html

let render (b : Blog.author) =
  let author =
    match b with
    | Blog.Author a -> a
    | Blog.Name { name; _ } ->
        (* Create a minimal author record for names *)
        {
          Author.name;
          title = None;
          hidden = true;
          avatar = None;
          slug = "";
          aliases = [];
          homepage = None;
        }
  in
  let avatar =
    Avatar.render { size = None; opacity = None; ring = None; author }
  in
  let title = match author.title with None -> [] | Some t -> [ txt t ] in
  div
    ~tw:
      [ Tw.relative; Tw.mt (Int 2); Tw.flex; Tw.items_center; Tw.gap_x (Int 4) ]
    [
      avatar;
      div
        ~tw:[ Tw.text_xs; Tw.leading_6 ]
        [
          p
            ~tw:[ Tw.font_semibold; Tw.text ~shade:600 Tw.Gray ]
            [ txt author.name ];
          p ~tw:[ Tw.text ~shade:600 Tw.Gray ] title;
        ];
    ]
