module F = Fmt
open Ui
open Html
module Fmt = F

(* Helper to take first n elements from a list *)
let take n list =
  let rec aux n acc = function
    | [] -> List.rev acc
    | _ when n <= 0 -> List.rev acc
    | h :: t -> aux (n - 1) (h :: acc) t
  in
  aux n [] list

(* Render post title and description *)
let render_post_content (post : Core.Blog.t) =
  Html.div ~tw:[ Tw.flex_1 ]
    [
      Html.h3
        ~tw:
          [
            Tw.text_lg;
            Tw.font_semibold;
            Tw.text ~shade:900 Gray;
            Tw.group_hover (Tw.text ~shade:700 Sky);
            Tw.transition_colors;
            Tw.mb (Int 2);
          ]
        [ Html.txt post.title ];
      Html.p
        ~tw:[ Tw.text_sm; Tw.text ~shade:600 Gray; Tw.leading_relaxed ]
        [ Html.txt post.description ];
    ]

(* Render post date *)
let render_post_date post =
  Html.time
    ~at:[ At.datetime (Core.Blog.date post) ]
    ~tw:[ Tw.text_sm; Tw.text ~shade:500 Gray; Tw.whitespace_nowrap ]
    [ Html.txt (Core.Blog.pretty_date post) ]

(* Render a single blog post preview *)
let render_post_preview (post : Core.Blog.t) =
  Html.article
    ~tw:
      [
        Tw.group;
        Tw.bg_white;
        Tw.p (Int 6);
        Tw.rounded_lg;
        Tw.border;
        Tw.border_color ~shade:200 Gray;
        Tw.hover Tw.shadow_lg;
        Tw.hover (Tw.border_color ~shade:300 Gray);
        Tw.transition_all;
      ]
    [
      Html.a
        ~at:[ At.href (Fmt.str "/blog/%s/" post.slug) ]
        ~tw:[ Tw.block; Tw.group ]
        [
          Html.div
            ~tw:[ Tw.flex; Tw.flex_col; Tw.sm Tw.flex_row; Tw.gap (Int 4) ]
            [ render_post_content post; render_post_date post ];
        ];
    ]

(* Render recent posts section *)
let render_recent_posts recent_posts =
  if List.length recent_posts = 0 then Html.empty
  else
    Html.section
      ~tw:[ Tw.py (Int 8); Tw.bg ~shade:50 Gray ]
      [
        Html.div
          ~tw:[ Tw.max_w_4xl; Tw.mx_auto; Tw.px (Int 6) ]
          [
            Html.div
              ~tw:
                [ Tw.border_t; Tw.border_color ~shade:200 Gray; Tw.pt (Int 8) ]
              [
                Html.h2
                  ~tw:
                    [
                      Tw.sm Tw.text_2xl;
                      Tw.font_bold;
                      Tw.text ~shade:900 Gray;
                      Tw.mb (Int 6);
                    ]
                  [ Html.txt "Recent Writing" ];
                Html.div
                  ~tw:[ Tw.space_y (Int 4) ]
                  (List.map render_post_preview recent_posts);
                Html.div
                  ~tw:[ Tw.mt (Int 6) ]
                  [
                    Html.a
                      ~at:[ At.href "/blog/" ]
                      ~tw:
                        [
                          Tw.inline_flex;
                          Tw.items_center;
                          Tw.text_sm;
                          Tw.text ~shade:700 Gray;
                          Tw.font_medium;
                          Tw.hover (Tw.text ~shade:900 Gray);
                          Tw.transition_colors;
                        ]
                      [
                        Html.txt "View all posts";
                        Html.span ~tw:[ Tw.ml (Int 1) ] [ Html.txt "→" ];
                      ];
                  ];
              ];
          ];
      ]

(* Render markdown content section *)
let render_content_section page =
  Html.section
    ~tw:[ Tw.pt (Int 8); Tw.pb (Int 8); Tw.bg_white ]
    [
      Html.div
        ~tw:[ Tw.max_w_4xl; Tw.mx_auto; Tw.px_6 ]
        [
          Html.div
            ~tw:[ Tw.prose; Tw.prose_sm; Tw.max_w_none ]
            [ Html.raw page.Core.Static.body_html ];
        ];
    ]

(* Main render function *)
let render ~site ~static_pages ~blog_posts =
  let static_page =
    List.find_opt (fun p -> p.Core.Static.name = "index") static_pages
  in
  let recent_posts = take 2 blog_posts in

  match static_page with
  | None ->
      (* Fallback if no index.md exists *)
      Ui.Layout.render ~title:site.Core.Site.name
        ~description:site.Core.Site.description ~site Core.Page.Index
        [
          Ui.Hero.render
            {
              style = Some Gradient;
              title = site.Core.Site.name;
              description = site.Core.Site.tagline;
              subtitle = None;
              palette = Ui.Colors.default_palette;
            };
          render_recent_posts recent_posts;
        ]
  | Some page ->
      (* Use content from index.md *)
      let description = Option.value ~default:"" page.description in
      Ui.Layout.render ~title:page.title ~description ~site Core.Page.Index
        [
          Ui.Hero.render
            {
              style = Some Gradient;
              title = page.title;
              description = site.Core.Site.tagline;
              subtitle = None;
              palette = Ui.Colors.default_palette;
            };
          render_content_section page;
          render_recent_posts recent_posts;
        ]

let file = __FILE__
