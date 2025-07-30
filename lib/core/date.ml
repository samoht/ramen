(** Date formatting utilities *)

let month_to_string = function
  | 1 -> "Jan"
  | 2 -> "Feb"
  | 3 -> "Mar"
  | 4 -> "Apr"
  | 5 -> "May"
  | 6 -> "Jun"
  | 7 -> "Jul"
  | 8 -> "Aug"
  | 9 -> "Sep"
  | 10 -> "Oct"
  | 11 -> "Nov"
  | 12 -> "Dec"
  | _ -> failwith "Invalid month"

let weekday_to_string = function
  | `Mon -> "Mon"
  | `Tue -> "Tue"
  | `Wed -> "Wed"
  | `Thu -> "Thu"
  | `Fri -> "Fri"
  | `Sat -> "Sat"
  | `Sun -> "Sun"

let normalize_date date =
  match Ptime.of_rfc3339 (date ^ "T12:00:00.00Z") with
  | Ok (time, _, _) ->
      let year, month, day = Ptime.to_date time in
      let weekday = weekday_to_string (Ptime.weekday time) in
      let day_str =
        if day < 10 then "0" ^ string_of_int day else string_of_int day
      in
      Pp.str
        [ weekday; ", "; day_str; " "; month_to_string month; " "; Pp.int year ]
  | Error _ -> date

let pretty_date = normalize_date
