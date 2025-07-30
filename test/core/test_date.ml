(** Tests for the Date module *)

open Alcotest

let test_month_to_string () =
  check string "January" "Jan" (Core.Date.month_to_string 1);
  check string "February" "Feb" (Core.Date.month_to_string 2);
  check string "March" "Mar" (Core.Date.month_to_string 3);
  check string "April" "Apr" (Core.Date.month_to_string 4);
  check string "May" "May" (Core.Date.month_to_string 5);
  check string "June" "Jun" (Core.Date.month_to_string 6);
  check string "July" "Jul" (Core.Date.month_to_string 7);
  check string "August" "Aug" (Core.Date.month_to_string 8);
  check string "September" "Sep" (Core.Date.month_to_string 9);
  check string "October" "Oct" (Core.Date.month_to_string 10);
  check string "November" "Nov" (Core.Date.month_to_string 11);
  check string "December" "Dec" (Core.Date.month_to_string 12)

let test_weekday_to_string () =
  check string "Monday" "Mon" (Core.Date.weekday_to_string `Mon);
  check string "Tuesday" "Tue" (Core.Date.weekday_to_string `Tue);
  check string "Wednesday" "Wed" (Core.Date.weekday_to_string `Wed);
  check string "Thursday" "Thu" (Core.Date.weekday_to_string `Thu);
  check string "Friday" "Fri" (Core.Date.weekday_to_string `Fri);
  check string "Saturday" "Sat" (Core.Date.weekday_to_string `Sat);
  check string "Sunday" "Sun" (Core.Date.weekday_to_string `Sun)

let test_normalize_date () =
  (* Test valid date *)
  let normalized = Core.Date.normalize_date "2024-01-15" in
  check bool "contains month" true
    (Astring.String.is_infix ~affix:"Jan" normalized);
  check bool "contains year" true
    (Astring.String.is_infix ~affix:"2024" normalized);
  check bool "contains day" true
    (Astring.String.is_infix ~affix:"15" normalized);

  (* Test invalid date - should return original *)
  let invalid = Core.Date.normalize_date "invalid-date" in
  check string "invalid date unchanged" "invalid-date" invalid

let test_pretty_date () =
  (* pretty_date is an alias for normalize_date *)
  let date = "2023-12-25" in
  check string "pretty_date equals normalize_date"
    (Core.Date.normalize_date date)
    (Core.Date.pretty_date date)

let suite =
  [
    ( "date",
      [
        test_case "month_to_string" `Quick test_month_to_string;
        test_case "weekday_to_string" `Quick test_weekday_to_string;
        test_case "normalize_date" `Quick test_normalize_date;
        test_case "pretty_date" `Quick test_pretty_date;
      ] );
  ]
