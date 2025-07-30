(** Tests for the File module *)

open Alcotest

let test_creation () =
  let simple_file =
    {
      Core.File.origin = "images/logo.png";
      target = File { url = "/images/logo.png" };
    }
  in

  check string "file origin" "images/logo.png" simple_file.origin;
  match simple_file.target with
  | File path -> check string "file url" "/images/logo.png" path.url
  | Responsive _ -> fail "Expected File, got Responsive"

let test_responsive_file () =
  let responsive =
    {
      Core.File.origin = "images/hero.jpg";
      target =
        Responsive
          {
            main = (1920, { url = "/images/hero-1920.jpg" });
            alternates =
              [
                ({ url = "/images/hero-640.jpg" }, 640);
                ({ url = "/images/hero-1280.jpg" }, 1280);
              ];
          };
    }
  in

  check string "responsive origin" "images/hero.jpg" responsive.origin;
  match responsive.target with
  | File _ -> fail "Expected Responsive, got File"
  | Responsive r ->
      let width, path = r.main in
      check int "main width" 1920 width;
      check string "main url" "/images/hero-1920.jpg" path.url;
      check int "alternates count" 2 (List.length r.alternates)

let test_url () =
  let simple_url = Core.File.Url "/assets/style.css" in
  let responsive_url =
    Core.File.Responsive
      {
        src = "/images/banner.jpg";
        srcset = "/images/banner-640.jpg 640w, /images/banner-1280.jpg 1280w";
        sizes = "(max-width: 640px) 640px, 1280px";
      }
  in

  (match simple_url with
  | Url s -> check string "simple url" "/assets/style.css" s
  | _ -> fail "Expected Url");

  match responsive_url with
  | Responsive r ->
      check string "responsive src" "/images/banner.jpg" r.src;
      check bool "has srcset" true (String.length r.srcset > 0)
  | _ -> fail "Expected Responsive"

let test_pp () =
  let file =
    {
      Core.File.origin = "css/main.css";
      target = File { url = "/css/main.css" };
    }
  in

  let pp_output = Core.File.pp file in
  check bool "pp contains origin" true
    (Astring.String.is_infix ~affix:"css/main.css" pp_output);
  check bool "pp contains url" true
    (Astring.String.is_infix ~affix:"/css/main.css" pp_output)

let test_url_of_target () =
  let simple_target = Core.File.File { url = "/images/logo.png" } in
  let url = Core.File.url_of_target simple_target in
  check bool "simple file url" true
    (match url with Core.File.Url s -> s = "/images/logo.png" | _ -> false);

  let responsive_target : Core.File.target =
    Core.File.Responsive
      {
        main = (1920, { url = "/images/hero-1920.jpg" });
        alternates =
          [
            ({ url = "/images/hero-640.jpg" }, 640);
            ({ url = "/images/hero-1280.jpg" }, 1280);
          ];
      }
  in
  let resp_url = Core.File.url_of_target responsive_target in
  match resp_url with
  | Core.File.Responsive r ->
      check string "responsive src" "/images/hero-1280.jpg" r.src;
      check bool "has srcset" true (String.length r.srcset > 0);
      check bool "has sizes" true (String.length r.sizes > 0)
  | _ -> fail "Expected Responsive url"

let test_href () =
  let simple_file =
    {
      Core.File.origin = "images/logo.png";
      target = File { url = "/images/logo.png" };
    }
  in
  check string "simple file href" "/images/logo.png"
    (Core.File.href simple_file);

  let responsive_file =
    {
      Core.File.origin = "images/hero.jpg";
      target =
        Responsive
          {
            main = (1920, { url = "/images/hero-1920.jpg" });
            alternates =
              [
                ({ url = "/images/hero-640.jpg" }, 640);
                ({ url = "/images/hero-1280.jpg" }, 1280);
              ];
          };
    }
  in
  check string "responsive file href" "/images/hero-1280.jpg"
    (Core.File.href responsive_file)

let suite =
  [
    ( "file",
      [
        test_case "simple file" `Quick test_creation;
        test_case "responsive file" `Quick test_responsive_file;
        test_case "file url types" `Quick test_url;
        test_case "pretty printing" `Quick test_pp;
        test_case "url_of_target" `Quick test_url_of_target;
        test_case "href" `Quick test_href;
      ] );
  ]
