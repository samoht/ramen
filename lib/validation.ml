(** Runtime validation with helpful error messages *)

type error = {
  file : string;
  line : int option;
  field : string option;
  message : string;
}

exception Validation_error of error

let pp_error ppf e =
  (* First print location info in a clear format *)
  (match (e.line, e.field) with
  | Some line, Some field ->
      Fmt.pf ppf "@[<v>%a in %a (line %d)@,Field: %a@,@]"
        Fmt.(styled `Bold string)
        "Validation Error"
        Fmt.(styled (`Fg `Blue) string)
        e.file line
        Fmt.(styled (`Fg `Yellow) string)
        field
  | Some line, None ->
      Fmt.pf ppf "@[<v>%a in %a (line %d)@,@]"
        Fmt.(styled `Bold string)
        "Validation Error"
        Fmt.(styled (`Fg `Blue) string)
        e.file line
  | None, Some field ->
      Fmt.pf ppf "@[<v>%a in %a@,Field: %a@,@]"
        Fmt.(styled `Bold string)
        "Validation Error"
        Fmt.(styled (`Fg `Blue) string)
        e.file
        Fmt.(styled (`Fg `Yellow) string)
        field
  | None, None ->
      Fmt.pf ppf "@[<v>%a in %a@,@]"
        Fmt.(styled `Bold string)
        "Validation Error"
        Fmt.(styled (`Fg `Blue) string)
        e.file);
  (* Then print the error message on a new line *)
  Fmt.pf ppf "@[<v>%a %s@]" Fmt.(styled (`Fg `Red) string) "Problem:" e.message

let error ?line ~file ~field message =
  raise (Validation_error { file; line; field = Some field; message })

let _validate_required ?line ~file ~field = function
  | None ->
      error ?line ~file ~field
        (Fmt.str
           "Missing required field.@.@.Tip: Add '%s' to your file with an \
            appropriate value."
           field)
  | Some v -> v

let validate_date ?line ~file ~field date =
  let is_valid_date s =
    match Scanf.sscanf_opt s "%4d-%2d-%2d" (fun y m d -> (y, m, d)) with
    | Some (y, m, d)
      when y >= 1900 && y <= 2100 && m >= 1 && m <= 12 && d >= 1 && d <= 31 ->
        true
    | _ -> false
  in
  if not (is_valid_date date) then
    error ?line ~file ~field
      (Fmt.str
         "Invalid date format: '%s'@.@.Tip: Use the format YYYY-MM-DD (e.g., \
          2024-01-15)"
         date)

let _validate_slug ?line ~file ~field slug =
  let is_valid_slug s =
    String.for_all
      (function 'a' .. 'z' | '0' .. '9' | '-' -> true | _ -> false)
      s
  in
  if not (is_valid_slug slug) then
    error ?line ~file ~field
      (Fmt.str
         "Invalid slug: '%s'@.@.Tip: Use only lowercase letters, numbers, and \
          hyphens (e.g., 'my-blog-post')@.   No spaces, special characters, or \
          uppercase letters allowed."
         slug)

let validate_url ?line ~file ~field url =
  match Uri.of_string url with
  | exception _ ->
      error ?line ~file ~field
        (Fmt.str
           "Invalid URL format: '%s'@.@.Tip: URLs should start with http:// or \
            https:// (e.g., 'https://example.com')"
           url)
  | uri -> (
      match Uri.scheme uri with
      | Some ("http" | "https") -> ()
      | Some scheme ->
          error ?line ~file ~field
            (Fmt.str
               "Unsupported URL scheme: '%s'@.@.Tip: Use http:// or https:// \
                URLs only."
               scheme)
      | None ->
          (* Allow relative URLs *)
          ())

let validate_email ?line ~file ~field email =
  let is_valid_email e =
    match String.split_on_char '@' e with
    | [ local; domain ] when String.length local > 0 && String.length domain > 0
      ->
        String.contains domain '.'
    | _ -> false
  in
  if not (is_valid_email email) then
    error ?line ~file ~field
      (Fmt.str
         "Invalid email address: '%s'@.@.Tip: Use a valid email format (e.g., \
          'user@example.com')"
         email)

let validate_image_path ?line ~file ~field path =
  let valid_extensions = [ ".jpg"; ".jpeg"; ".png"; ".webp"; ".svg"; ".gif" ] in
  let ext = String.lowercase_ascii (Filename.extension path) in
  if not (List.mem ext valid_extensions) then
    error ?line ~file ~field
      (Fmt.str
         "Unsupported image format: '%s'@.@.Tip: Use one of these formats: \
          %s@.   Example: 'banner.jpg' or 'logo.png'"
         ext
         (String.concat ", " valid_extensions))

let validate_team_member ~file (m : Core.Author.t) =
  if m.name = "" then
    error ~file ~field:"name"
      "Team member name is required.@.@.Tip: Add the person's full name (e.g., \
       'Jane Doe')";
  match m.avatar with
  | Some path -> validate_image_path ~file ~field:"avatar" path
  | None -> ()

let validate_author = validate_team_member

let validate_blog_post ~file (p : Core.Blog.t) =
  if p.title = "" then
    error ~file ~field:"title"
      "Blog post title is required.@.@.Tip: Add a descriptive title for your \
       post (e.g., 'Getting Started with OCaml')";
  validate_date ~file ~field:"date" p.date;
  validate_image_path ~file ~field:"image" p.image;
  if List.length p.authors = 0 then
    error ~file ~field:"author"
      "Blog post must have at least one author.@.@.Tip: Add 'author: \
       your-name' or 'authors: [author1, author2]' to the frontmatter."

let validate_site_config ~file (s : Core.Site.t) =
  if s.name = "" then
    error ~file ~field:"name"
      "Site name is required.@.@.Tip: This is your site's identifier (e.g., \
       'my-blog')";
  if s.title = "" then
    error ~file ~field:"title"
      "Site title is required.@.@.Tip: This appears in the browser tab (e.g., \
       'My Personal Blog')";
  if s.author = "" then
    error ~file ~field:"author"
      "Site author is required.@.@.Tip: Add your name as the default site \
       author.";
  validate_email ~file ~field:"author_email" s.author_email;
  validate_url ~file ~field:"url" s.url;
  let footer = s.Core.Site.footer in
  List.iter
    (fun (link : Core.Site.link) ->
      validate_url ~file ~field:"footer.link.url" link.href)
    footer.links

let validate_static_page ~file (p : Core.Page.static) =
  if p.title = "" then
    error ~file ~field:"title"
      "Page title is required.@.@.Tip: Add a descriptive title for this page.";
  let valid_layouts = [ "default"; "minimal"; "full-width" ] in
  if not (List.mem p.layout valid_layouts) then
    error ~file ~field:"layout"
      (Fmt.str
         "Unknown layout: '%s'@.@.Tip: Use one of these layouts: %s@.   \
          Example: 'layout: default'"
         p.layout
         (String.concat ", " valid_layouts))

let validate_paper ~file (p : Core.Paper.t) =
  if p.title = "" then
    error ~file ~field:"title"
      "Paper title is required.@.@.Tip: Add the full title of your research \
       paper.";
  if List.length p.authors = 0 then
    error ~file ~field:"authors"
      "Paper must have at least one author.@.@.Tip: List all paper authors in \
       the 'authors' field.";
  List.iter
    (fun (f : Core.Paper.file) ->
      validate_url ~file ~field:"files.url" f.Core.Paper.url)
    p.files

(* Validate all loaded data *)
let validate_all (data : Core.t) =
  try
    validate_site_config ~file:"site.yml" data.site;
    List.iter (validate_team_member ~file:"team.yml") data.authors;
    List.iter
      (fun p -> validate_blog_post ~file:p.Core.Blog.path p)
      data.blog_posts;
    List.iter
      (fun p -> validate_static_page ~file:(p.Core.Static.name ^ ".md") p)
      data.static_pages;
    List.iter (validate_paper ~file:"papers.json") data.papers;
    Ok ()
  with Validation_error e -> Error e
