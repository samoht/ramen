open Core
open Html
open Tw

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
        px (int 3);
        py (int 2);
        rounded lg;
        text_sm;
        font_medium;
        text white;
        bg ~shade:700 sky;
      ]
    else
      [
        px (int 3);
        py (int 2);
        rounded lg;
        text_sm;
        font_medium;
        text ~shade:100 sky;
        on_hover [ bg ~shade:800 sky; text white ];
      ]
  in
  a ~at:[ At.href (page_href item.page) ] ~tw:classes [ txt item.label ]

let render_brand site_name =
  div ~tw:[ flex_shrink_0 ]
    [
      a
        ~at:[ At.href "/" ]
        ~tw:[ text white; font_bold; text_xl ]
        [ txt site_name ];
    ]

let render_menu menu active_page =
  div
    ~tw:[ hidden; on_md [ block ] ]
    [
      div
        ~tw:[ ml (int 10); flex; items_baseline; gap (int 4) ]
        (List.map (fun item -> menu_link item active_page) menu);
    ]

let render_external_links palette links =
  div
    ~tw:[ hidden; on_md [ block ] ]
    [
      div
        ~tw:[ ml (int 4); flex; items_center; on_md [ ml (int 6) ] ]
        (List.map (fun link -> Link.external_nav ~palette link) links);
    ]

let render t =
  let menu = Option.value t.menu ~default:default_menu in
  let active_page = t.active_page in
  let palette = t.palette in
  let links = [ Link.ocaml_org; Link.github_org ] in
  nav
    ~tw:[ bg ~shade:900 sky ]
    [
      div
        ~tw:
          [
            mx auto;
            max_w (rem 80.0) (* 7xl = 80rem *);
            px (int 4);
            px (int 6);
            px (int 8);
          ]
        [
          div
            ~tw:[ flex; h (int 16); items_center; justify_between ]
            [
              div ~tw:[ flex; items_center ]
                [
                  render_brand t.site.name;
                  render_menu menu active_page;
                ];
              render_external_links palette links;
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
