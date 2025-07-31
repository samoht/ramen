(** Tests for the Socials component *)

open Alcotest

let test_render_all () =
  let site =
    {
      Core.Site.name = "Test";
      url = "https://test.com";
      title = "Test";
      tagline = "Test";
      description = "Test";
      author = "Test";
      author_email = "test@test.com";
      social =
        Some
          {
            twitter = Some "@test";
            github = Some "testuser";
            linkedin = Some "test-profile";
          };
      analytics = None;
      footer = { copyright = "Test"; links = [] };
      posts_per_page = Some 10;
    }
  in

  let socials =
    { Ui.Socials.hover = None; site; palette = Ui.Colors.default_palette }
  in

  let links = Ui.Socials.render socials in

  (* Should have 4 links: twitter, github, linkedin, and RSS *)
  check int "four social links" 4 (List.length links);

  (* Check each contains correct icon *)
  let html_strs = List.map Ui.Html.to_string links in
  let all_html = String.concat "" html_strs in

  check bool "has twitter link" true
    (Astring.String.is_infix ~affix:"twitter.com" all_html);
  check bool "has github link" true
    (Astring.String.is_infix ~affix:"github.com" all_html);
  check bool "has linkedin link" true
    (Astring.String.is_infix ~affix:"linkedin.com" all_html)

let test_render_partial () =
  let site =
    {
      Core.Site.name = "Test";
      url = "https://test.com";
      title = "Test";
      tagline = "Test";
      description = "Test";
      author = "Test";
      author_email = "test@test.com";
      social =
        Some { twitter = None; github = Some "onlygithub"; linkedin = None };
      analytics = None;
      footer = { copyright = "Test"; links = [] };
      posts_per_page = Some 10;
    }
  in

  let socials =
    {
      Ui.Socials.hover = Some [ Ui.Tw.text ~shade:600 Ui.Tw.blue ];
      site;
      palette = Ui.Colors.default_palette;
    }
  in

  let links = Ui.Socials.render socials in

  (* Should have 2 links: github and RSS *)
  check int "two social links" 2 (List.length links);

  (* Check both links are present *)
  let html_strs = List.map Ui.Html.to_string links in
  let all_html = String.concat " " html_strs in

  check bool "has github link" true
    (Astring.String.is_infix ~affix:"github.com" all_html);
  check bool "has rss link" true
    (Astring.String.is_infix ~affix:"feed.xml" all_html);
  check bool "has hover class" true
    (Astring.String.is_infix ~affix:"hover:" (String.concat "" html_strs))

let test_render_none () =
  let site =
    {
      Core.Site.name = "Test";
      url = "https://test.com";
      title = "Test";
      tagline = "Test";
      description = "Test";
      author = "Test";
      author_email = "test@test.com";
      social = None;
      analytics = None;
      footer = { copyright = "Test"; links = [] };
      posts_per_page = Some 10;
    }
  in

  let socials =
    { Ui.Socials.hover = None; site; palette = Ui.Colors.default_palette }
  in

  let links = Ui.Socials.render socials in
  (* Should have 1 link: RSS only *)
  check int "one social link (RSS)" 1 (List.length links);

  let html_str = Ui.Html.to_string (List.hd links) in
  check bool "only rss link" true
    (Astring.String.is_infix ~affix:"feed.xml" html_str)

let suite =
  [
    ( "socials",
      [
        test_case "render all" `Quick test_render_all;
        test_case "render partial" `Quick test_render_partial;
        test_case "render none" `Quick test_render_none;
      ] );
  ]
