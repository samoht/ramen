(** Paper types *)

type file = { name : string; url : string }
type author = { name : string; url : string option }

type t = {
  title : string;
  authors : author list;
  where : string;
  year : string;
  abstract : string option;
  files : file list;
}

let pp_file (file : file) =
  Pp.record [ ("name", Pp.quote file.name); ("url", Pp.quote file.url) ]

let pp_author author =
  Pp.record
    [ ("name", Pp.quote author.name); ("url", Pp.option Pp.quote author.url) ]

let pp t =
  Pp.record
    [
      ("title", Pp.quote t.title);
      ("authors", Pp.list pp_author t.authors);
      ("where", Pp.quote t.where);
      ("year", Pp.quote t.year);
      ("abstract", Pp.option Pp.quote t.abstract);
      ("files", Pp.list pp_file t.files);
    ]
