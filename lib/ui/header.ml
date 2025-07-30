open Core
open Html

(* Menu item type *)
type menu_item = { label : string; page : Page.t }

type t = {
  menu : menu_item list option;
  active_page : Page.t option;
  site : Site.t;
  palette : Colors.palette;
}
(** Component data for the header *)

let default_menu =
  [
    { label = "Home"; page = Page.Index };
    {
      label = "Blog";
      page =
        Page.Blog_index { filter = None; page = 1; posts = []; all_posts = [] };
    };
  ]

let page_href = function
  | Page.Index -> "/"
  | Page.Blog_index _ -> "/blog/"
  | Page.Blog_post p -> "/blog/" ^ p.slug ^ "/"
  | Page.Blog_feed -> "/feed.xml"
  | Page.Papers -> "/papers/"
  | Page.Static_page p -> "/" ^ p.name ^ "/"
  | Page.Error -> "/404"
  | Page.Sitemap -> "/sitemap.xml"
  | Page.Robots_txt -> "/robots.txt"

let menu_link item active_page =
  let is_active =
    match (item.page, active_page) with
    | Page.Index, Some Page.Index -> true
    | Page.Blog_index _, Some (Page.Blog_index _) -> true
    | Page.Blog_index _, Some (Page.Blog_post _) -> true
    | Page.Static_page p1, Some (Page.Static_page p2) -> p1.name = p2.name
    | p1, Some p2 -> p1 = p2
    | _ -> false
  in
  let classes =
    if is_active then
      [
        Tw.px_3;
        Tw.py_2;
        Tw.rounded_lg;
        Tw.text_sm;
        Tw.font_medium;
        Tw.text_white;
        Tw.bg ~shade:700 Tw.Sky;
      ]
    else
      [
        Tw.px_3;
        Tw.py_2;
        Tw.rounded_lg;
        Tw.text_sm;
        Tw.font_medium;
        Tw.text_sky_100;
        Tw.hover_bg_sky_800;
        Tw.hover_text_white;
      ]
  in
  a ~at:[ At.href (page_href item.page) ] ~tw:classes [ txt item.label ]

let render t =
  let menu = Option.value t.menu ~default:default_menu in
  let active_page = t.active_page in
  let palette = t.palette in
  let links = [ Link.ocaml_org; Link.github_org ] in
  nav ~tw:[ Tw.bg_sky_900 ]
    [
      div
        ~tw:[ Tw.mx_auto; Tw.max_w_7xl; Tw.px_4; Tw.px_6; Tw.px_8 ]
        [
          div
            ~tw:[ Tw.flex; Tw.h_16; Tw.items_center; Tw.justify_between ]
            [
              div
                ~tw:[ Tw.flex; Tw.items_center ]
                [
                  div ~tw:[ Tw.flex_shrink_0 ]
                    [
                      a
                        ~at:[ At.href "/" ]
                        ~tw:[ Tw.text_white; Tw.font_bold; Tw.text_xl ]
                        [ txt t.site.name ];
                    ];
                  div ~tw:[ Tw.hidden; Tw.md_block ]
                    [
                      div
                        ~tw:
                          [ Tw.ml_10; Tw.flex; Tw.items_baseline; Tw.space_x_4 ]
                        (List.map (fun item -> menu_link item active_page) menu);
                    ];
                ];
              div ~tw:[ Tw.hidden; Tw.md_block ]
                [
                  div
                    ~tw:[ Tw.ml_4; Tw.flex; Tw.items_center; Tw.md_ml_6 ]
                    (List.map
                       (fun link -> Link.external_nav ~palette link)
                       links);
                ];
            ];
        ];
    ]

let pp t =
  let pp_menu_item item =
    Core.Pp.record
      [ ("label", Core.Pp.quote item.label); ("page", Core.Page.pp item.page) ]
  in
  Core.Pp.record
    [
      ("menu", Core.Pp.option (Core.Pp.list pp_menu_item) t.menu);
      ("active_page", Core.Pp.option Core.Page.pp t.active_page);
      ("site", Core.Site.pp t.site);
      ("palette", Colors.pp_palette t.palette);
    ]
