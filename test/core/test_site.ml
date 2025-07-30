(** Tests for the Site module *)

open Alcotest

let site_testable = testable (Fmt.of_to_string Core.Site.pp) ( = )

let test_creation () =
  let site =
    {
      Core.Site.name = "My Site";
      url = "https://mysite.com";
      title = "My Personal Site";
      tagline = "Thoughts and projects";
      description = "A personal website for sharing thoughts and projects";
      author = "John Doe";
      author_email = "john@example.com";
      social =
        Some
          {
            twitter = Some "@johndoe";
            github = Some "johndoe";
            linkedin = Some "john-doe";
          };
      analytics = None;
      footer =
        {
          copyright = "© 2024 John Doe";
          links =
            [
              { href = "/about"; text = "About" };
              { href = "/contact"; text = "Contact" };
            ];
        };
      posts_per_page = Some 10;
    }
  in

  check string "site name" "My Site" site.name;
  check string "site url" "https://mysite.com" site.url;
  check string "site author" "John Doe" site.author;
  check int "footer link count" 2 (List.length site.footer.links);
  check (option int) "posts per page" (Some 10) site.posts_per_page

let test_social () =
  let social =
    {
      Core.Site.twitter = Some "@test";
      github = Some "testuser";
      linkedin = None;
    }
  in

  check (option string) "twitter" (Some "@test") social.twitter;
  check (option string) "github" (Some "testuser") social.github;
  check (option string) "no linkedin" None social.linkedin

let test_analytics () =
  let analytics = { Core.Site.google = Some "GA-123456"; piwik = None } in

  check (option string) "google analytics" (Some "GA-123456") analytics.google;
  check (option string) "no piwik" None analytics.piwik

let test_footer () =
  let footer =
    {
      Core.Site.copyright = "© 2024 Test";
      links =
        [
          { href = "/privacy"; text = "Privacy Policy" };
          { href = "/terms"; text = "Terms of Service" };
        ];
    }
  in

  check string "copyright" "© 2024 Test" footer.copyright;
  check int "link count" 2 (List.length footer.links);

  let first_link = List.hd footer.links in
  check string "first link href" "/privacy" first_link.href;
  check string "first link text" "Privacy Policy" first_link.text

let test_pp () =
  let site =
    {
      Core.Site.name = "Test Site";
      url = "https://test.com";
      title = "Test";
      tagline = "Testing";
      description = "Test site";
      author = "Tester";
      author_email = "test@test.com";
      social = None;
      analytics = None;
      footer = { copyright = "© Test"; links = [] };
      posts_per_page = Some 10;
    }
  in

  let pp_output = Core.Site.pp site in
  check bool "pp contains name" true
    (Astring.String.is_infix ~affix:"Test Site" pp_output);
  check bool "pp contains url" true
    (Astring.String.is_infix ~affix:"https://test.com" pp_output);
  check bool "pp contains author" true
    (Astring.String.is_infix ~affix:"Tester" pp_output)

let suite =
  [
    ( "site",
      [
        test_case "creation" `Quick test_creation;
        test_case "social" `Quick test_social;
        test_case "analytics" `Quick test_analytics;
        test_case "footer" `Quick test_footer;
        test_case "pretty printing" `Quick test_pp;
      ] );
  ]
