(** Blog post types *)

type name = { name : string; slug : string }
type author = Author of Author.t | Name of name

type t = {
  authors : author list;
  title : string;
  image : string;
  image_alt : string option;
  date : string;
  slug : string;
  tags : string list;
  synopsis : string;
  description : string;
  body_html : string;
  body_words : string list;
  path : string;
  link : string option;
  links : string list;
}

type filter = Tag of string | Author of author

type index = {
  filter : filter option;
  page : int;
  posts : t list;
  all_posts : t list;
}

(** Utility functions *)

let date t = t.date

let pretty_date t =
  let open Ptime in
  match of_rfc3339 t.date with
  | Ok (time, _, _) ->
      let year, month, day = to_date time in
      let month_name =
        match month with
        | 1 -> "January"
        | 2 -> "February"
        | 3 -> "March"
        | 4 -> "April"
        | 5 -> "May"
        | 6 -> "June"
        | 7 -> "July"
        | 8 -> "August"
        | 9 -> "September"
        | 10 -> "October"
        | 11 -> "November"
        | 12 -> "December"
        | _ -> "Unknown"
      in
      month_name ^ " " ^ string_of_int day ^ ", " ^ string_of_int year
  | Error _ -> t.date

let author_name (author : author) =
  match author with Author a -> a.Author.name | Name { name; _ } -> name

let author_slug (author : author) =
  match author with Author a -> a.Author.slug | Name { slug; _ } -> slug

let author_team (author : author) =
  match author with
  | Author a -> a
  | Name _ -> failwith "author_team: not a team member"

let pp_name name =
  Pp.record [ ("name", Pp.quote name.name); ("slug", Pp.quote name.slug) ]

let pp_author (author : author) =
  match author with
  | Author a -> Pp.str [ "Author "; Pp.parens (Author.pp a) ]
  | Name n -> Pp.str [ "Name "; Pp.parens (pp_name n) ]

let pp t =
  Pp.record
    [
      ("authors", Pp.list pp_author t.authors);
      ("title", Pp.quote t.title);
      ("image", Pp.quote t.image);
      ("image_alt", Pp.option Pp.quote t.image_alt);
      ("date", Pp.quote t.date);
      ("slug", Pp.quote t.slug);
      ("tags", Pp.list Pp.quote t.tags);
      ("synopsis", Pp.quote t.synopsis);
      ("description", Pp.quote t.description);
      ( "body_html",
        Pp.str [ "<html...>"; Pp.int (String.length t.body_html); " chars" ] );
      ("body_words", Pp.str [ Pp.int (List.length t.body_words); " words" ]);
      ("path", Pp.quote t.path);
      ("link", Pp.option Pp.quote t.link);
      ("links", Pp.list Pp.quote t.links);
    ]

let pp_filter filter =
  match filter with
  | Tag tag -> Pp.str [ "Tag "; Pp.quote tag ]
  | Author author -> Pp.str [ "Author "; Pp.parens (pp_author author) ]

let pp_index index =
  Pp.record
    [
      ("filter", Pp.option pp_filter index.filter);
      ("page", Pp.int index.page);
      ("posts", Pp.str [ Pp.int (List.length index.posts); " posts" ]);
      ( "all_posts",
        Pp.str [ Pp.int (List.length index.all_posts); " total posts" ] );
    ]

(* Utility functions *)

let filter_posts ?filter posts =
  match filter with
  | None -> posts
  | Some (Tag tag) -> List.filter (fun p -> List.mem tag p.tags) posts
  | Some (Author filter_author) ->
      List.filter
        (fun p ->
          List.exists
            (fun post_author ->
              match (post_author, filter_author) with
              | (Author t1 : author), (Author t2 : author) ->
                  t1.Author.slug = t2.Author.slug
              | (Name n1 : author), (Name n2 : author) -> n1.slug = n2.slug
              | _ -> false)
            p.authors)
        posts

let paginate ~posts_per_page posts page =
  let start_idx = (page - 1) * posts_per_page in
  let rec take n lst =
    match (n, lst) with 0, _ | _, [] -> [] | n, h :: t -> h :: take (n - 1) t
  in
  let rec drop n lst =
    match (n, lst) with
    | 0, lst -> lst
    | _, [] -> []
    | n, _ :: t -> drop (n - 1) t
  in
  drop start_idx posts |> take posts_per_page

let url_of_index i =
  let concat = String.concat "" in
  let param k v = concat [ k; "/"; v; "/" ] in
  let page =
    match i.page with 1 -> "" | n -> concat [ "page/"; string_of_int n; "/" ]
  in
  let filter =
    match i.filter with
    | None -> ""
    | Some (Author a) -> param "author" (author_slug a)
    | Some (Tag s) -> param "tag" s
  in
  concat [ "/blog/"; filter; page ]

(* Utilities for working with collections of blog posts *)

let all_tags posts =
  posts
  |> List.map (fun p -> p.tags)
  |> List.flatten
  |> List.sort_uniq String.compare

let all_authors posts =
  posts
  |> List.map (fun p -> p.authors)
  |> List.flatten
  |> List.sort_uniq (fun a1 a2 ->
         String.compare (author_slug a1) (author_slug a2))
