(** Tests for the Avatar component *)

open Alcotest

let test_render_opacity () =
  let author =
    {
      Core.Author.name = "Test Author";
      title = Some "Developer";
      hidden = false;
      avatar = Some "avatar.jpg";
      slug = "test-author";
      aliases = [];
      homepage = None;
    }
  in

  (* Test that opacity is correctly applied *)
  let avatar_with_opacity =
    {
      Ui.Avatar.size = Some Ui.Avatar.Size_10;
      opacity = Some Ui.Avatar.Opacity_50;
      ring = None;
      author;
    }
  in

  let avatar_without_opacity =
    {
      Ui.Avatar.size = Some Ui.Avatar.Size_10;
      opacity = None;
      ring = None;
      author;
    }
  in

  let html_with = Ui.Avatar.render avatar_with_opacity in
  let html_without = Ui.Avatar.render avatar_without_opacity in

  let str_with = Ui.Html.to_string html_with in
  let str_without = Ui.Html.to_string html_without in

  check bool "has opacity-50 when specified" true
    (Astring.String.is_infix ~affix:"opacity-50" str_with);
  check bool "no opacity class when not specified" false
    (Astring.String.is_infix ~affix:"opacity-" str_without)

let test_render_with_image () =
  let author =
    {
      Core.Author.name = "Jane Smith";
      title = Some "Developer";
      hidden = false;
      avatar = Some "/images/jane.jpg";
      slug = "jane-smith";
      aliases = [];
      homepage = None;
    }
  in

  let avatar =
    {
      Ui.Avatar.size = Some Ui.Avatar.Size_12;
      opacity = None;
      ring = Some 2;
      author;
    }
  in

  let html = Ui.Avatar.render avatar in
  let html_str = Ui.Html.to_string html in

  check bool "contains image src" true
    (Astring.String.is_infix ~affix:"/images/jane.jpg" html_str);
  check bool "has ring classes" false
    (Astring.String.is_infix ~affix:"ring-2" html_str)

let test_render_without_image () =
  let author =
    {
      Core.Author.name = "Bob Test";
      title = None;
      hidden = false;
      avatar = None;
      slug = "bob-test";
      aliases = [];
      homepage = None;
    }
  in

  let avatar =
    {
      Ui.Avatar.size = Some Ui.Avatar.Size_8;
      opacity = Some Ui.Avatar.Opacity_50;
      ring = None;
      author;
    }
  in

  let html = Ui.Avatar.render avatar in
  let html_str = Ui.Html.to_string html in

  check bool "shows initials" true
    (Astring.String.is_infix ~affix:"BT" html_str);
  check bool "has opacity" true
    (Astring.String.is_infix ~affix:"opacity-50" html_str)

let suite =
  [
    ( "avatar",
      [
        test_case "render with opacity" `Quick test_render_opacity;
        test_case "render with image" `Quick test_render_with_image;
        test_case "render without image" `Quick test_render_without_image;
      ] );
  ]
