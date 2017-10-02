let src = Logs.Src.create "ramen"
module Log = (val Logs.src_log src: Logs.LOG)

type t =
  | Data of string
  | Var of string
  | For of loop
  | Seq of t list

and loop = {
  var   : string;
  map   : string;
  order : string option;
  body  : t;
}

let rec pp ppf = function
  | Data s -> Fmt.string ppf s
  | Var v  -> Fmt.pf ppf "{{ %s }}" v
  | Seq l  -> Fmt.(list ~sep:(unit "") pp) ppf l
  | For l  -> pp_loop ppf l

and pp_loop ppf t =
  let o ppf = match t.order with
    | None   -> Fmt.string ppf ""
    | Some s -> Fmt.pf ppf " | %s" s
  in
  Fmt.pf ppf "{{ for %s in %s%t }}%a{{ endfor }}" t.var t.map o pp t.body

let rec dump ppf = function
  | Data s -> Fmt.pf ppf "@[<hov 2>Data %S@]" s
  | Var v  -> Fmt.pf ppf "@[<hov 2>Var %s@]" v
  | Seq l  -> Fmt.pf ppf "@[<hov 2>Seq %a@]" Fmt.(Dump.list dump) l
  | For l  -> pp_loop ppf l

and pp_loop ppf t =
  Fmt.pf ppf "@[<hov 2>For@ {var=%s;@ map=%s;@ order=%a;@ body=%a}@]"
    t.var t.map Fmt.(Dump.option string) t.order dump t.body

let rec equal x y =
  x == y ||
  match x, y with
  | Data x, Data y -> String.equal x y
  | Var x , Var y  -> String.equal x y
  | Seq x , Seq y  -> List.length x = List.length y && List.for_all2 equal x y
  | For x , For y  -> equal_loop x y
  | _ -> false

and equal_loop x y =
  String.equal x.var y.var
  && String.equal x.map y.map
  && order_equal x.order y.order
  && equal x.body y.body

and order_equal x y = match x, y with
  | None  , None  -> true
  | Some x, Some y -> String.equal x y
  | _ -> false
