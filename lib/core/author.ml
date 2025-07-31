(** Author type *)

type t = {
  name : string;
  title : string option;
  hidden : bool;
  avatar : string option;
  slug : string;
  aliases : string list;
  homepage : string option;
}

let pp t =
  Pp.record
    [
      ("name", Pp.quote t.name);
      ("title", Pp.option Pp.quote t.title);
      ("hidden", Pp.bool t.hidden);
      ("avatar", Pp.option Pp.quote t.avatar);
      ("slug", Pp.quote t.slug);
      ("aliases", Pp.list Pp.quote t.aliases);
      ("homepage", Pp.option Pp.quote t.homepage);
    ]

(* Utilities for working with collections of authors *)

let by_name authors name =
  let normalize s =
    s |> String.lowercase_ascii
    |> String.map (function '\'' -> '-' | ' ' -> '-' | c -> c)
    |> String.split_on_char '-'
    |> List.filter (( <> ) "")
    |> String.concat "-"
  in
  let slug = normalize name in
  List.find_opt
    (fun (t : t) ->
      String.lowercase_ascii t.slug = slug
      || List.mem name t.aliases
      || List.mem
           (String.lowercase_ascii name)
           (List.map String.lowercase_ascii t.aliases))
    authors
