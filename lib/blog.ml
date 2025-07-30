(** Blog posts module *)

(* To please ppx_import *)
module Core__ = struct
  module Author = Author
end

type name = [%import: Core.Blog.name] [@@deriving show, yaml]
type author = [%import: Core.Blog.author] [@@deriving show, yaml]
type t = [%import: Core.Blog.t] [@@deriving show]

(* Flexible parsing type that handles various frontmatter formats *)
type raw = {
  title : string;
  author : string option;
  authors : string option;
  date : string;
  tags : string option;
  synopsis : string;
  description : string option;
  image : string;
  image_alt : string option; [@key "image-alt"]
}
[@@deriving yaml]

(* Handle comma/ampersand-separated author strings *)
let split_authors a =
  let split =
    Astring.String.fields ~empty:false ~is_sep:(function
      | ',' | '&' -> true
      | _ -> false)
  in
  let authors =
    match Astring.String.cut ~rev:true ~sep:" and " a with
    | Some (x, y) -> split x @ [ y ]
    | None -> split a
  in
  List.map String.trim authors

(* Handle comma-separated tag strings *)
let split_tags ts =
  let tags = Astring.String.cuts ~sep:"," ~empty:false ts in
  let tags = List.map String.trim tags in
  let tags = List.map String.lowercase_ascii tags in
  List.sort String.compare tags

(* Generate URL slug from date and title *)
let make_slug date title =
  let buf = Buffer.create 13 in
  let title = String.lowercase_ascii title in
  let clean = ref true in
  Buffer.add_string buf date;
  clean := false;
  String.iter
    (function
      | ('a' .. 'z' | '0' .. '9') as x ->
          if not !clean then (
            Buffer.add_char buf '-';
            clean := true);
          Buffer.add_char buf x
      | _ -> clean := false)
    title;
  Buffer.contents buf

(* Convert markdown to HTML *)
let html_of_md body =
  let doc = Cmarkit.Doc.of_string body in
  Cmarkit_html.of_doc ~safe:false doc

(* Extract words from markdown body *)
let words_of_md body =
  let text = Re.replace_string (Re.Pcre.regexp "[^a-zA-Z0-9 ]") ~by:" " body in
  let words = Re.split (Re.Pcre.regexp " +") text in
  List.filter (fun w -> String.length w > 0) words

(* Convert parsed frontmatter to Blog.t - similar to tarides.com of_metadata *)
let of_raw ~body ~path fm =
  let tags = match fm.tags with None -> [] | Some t -> split_tags t in
  let synopsis = fm.synopsis in
  let description =
    match fm.description with Some d -> d | None -> synopsis
  in
  let authors =
    let author_names =
      match (fm.authors, fm.author) with
      | Some authors_str, _ -> split_authors authors_str
      | None, Some author_name -> [ author_name ]
      | None, None -> failwith "Missing 'author' or 'authors' field"
    in
    List.map
      (fun name ->
        let slug =
          Re.replace_string (Re.Pcre.regexp " ") ~by:"-"
            (String.lowercase_ascii name)
        in
        Name { name; slug })
      author_names
  in
  let slug = make_slug fm.date fm.title in
  let body_html = html_of_md body in
  let body_words = words_of_md body in
  {
    authors;
    title = fm.title;
    image = fm.image;
    image_alt = fm.image_alt;
    date = fm.date;
    slug;
    tags;
    synopsis;
    description;
    body_html;
    body_words;
    path;
    link = None;
    links = [];
  }

type filter = [%import: Core.Blog.filter] [@@deriving show]
type index = [%import: Core.Blog.index] [@@deriving show]

(* Load a single blog post from file *)
let load_post blog_dir file =
  let path = Filename.concat blog_dir file in
  let content =
    match Bos.OS.File.read (Fpath.v path) with
    | Ok c -> c
    | Error (`Msg e) -> failwith (Fmt.str "Failed to read %s: %s" path e)
  in
  match Frontmatter.parse content with
  | Ok (Some fm) -> (
      match raw_of_yaml fm.Frontmatter.yaml with
      | Ok parsed_fm ->
          let post = of_raw ~body:fm.body ~path:file parsed_fm in
          Ok post
      | Error (`Msg e) -> Error (Fmt.str "YAML parsing error in %s: %s" file e))
  | Ok None -> Error (Fmt.str "No frontmatter found in %s" file)
  | Error e ->
      Error
        (Fmt.str "Frontmatter parsing error in %s: %s" file
           (match e with
           | Unclosed_delimiter -> "unclosed delimiter"
           | Yaml_parse_error msg -> msg))

let load ~dir =
  let blog_dir = Filename.concat dir "blog/content" in
  if not (Sys.file_exists blog_dir) then Ok []
  else
    let files =
      Sys.readdir blog_dir |> Array.to_list
      |> List.filter (fun f -> Filename.check_suffix f ".md")
    in
    let rec load_all acc = function
      | [] -> Ok (List.rev acc)
      | file :: rest -> (
          match load_post blog_dir file with
          | Ok post -> load_all (post :: acc) rest
          | Error e -> Error e)
    in
    load_all [] files
