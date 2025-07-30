(** Static page types and utilities *)

type t = {
  title : string;
  description : string option;
  layout : string;
  name : string;
  body_html : string;
  in_nav : bool; (* Whether to show in navigation *)
  nav_order : int option; (* Optional ordering in navigation *)
}

let pp t =
  Pp.record
    [
      ("title", Pp.quote t.title);
      ("description", Pp.option Pp.quote t.description);
      ("layout", Pp.quote t.layout);
      ("name", Pp.quote t.name);
      ("body_html", "...");
      ("in_nav", Pp.bool t.in_nav);
      ("nav_order", Pp.option Pp.int t.nav_order);
    ]
