open Gserver
open Users
open Recommender
open Yojson.Basic.Util
open Yojson


(****************************************************************************)
(* Quantities specify how many users will be of a certain year or in a
 * certain club. We are using them to make the results of the bot less random
 * so that the simulation is more realistic.*)

(* [Freshman | Sophomore | Junior | Senior] *)
let year_quantities = [60; 90; 90; 70]

(* [ACSU | WICC | URMC | CDS | COS | AD | CCC | NONE] *)
let club_quantities = [16; 28; 29; 31; 32; 34; 35]

(****************************************************************************)

(* [total] is the total number of users this bot will produce*)
let total = List.fold_left (+) 0 year_quantities

(* [distr_tuple l] is a tuple containing information about [l].
 *        - (sum of elements in [l], a reversed distribution list of [l])
 * A distribution list the same size as [l] such that each element is the
 * sum of all elements previous elements. *)
let distr_tuple l = List.fold_left (fun (acc1, acc2) x ->
    let res = x + acc1 in
    (res, res::acc2)) (0, []) l

(* [make_distr] is the distribution list of [l]*)
let make_distr l =  distr_tuple l |> snd |> List.rev

(* [year_distr] is the distribution list of year_quantities*)
let year_distr = make_distr year_quantities

(* [club_distr] is the distributino list of club_quantities*)
let club_distr = make_distr club_quantities

(* [json_preuser pre] converts a pre_user to JSON format. *)
let json_preuser (pre:pre_user) =
  try (
  let (intros,cores) = List.partition (fun (r,cl) -> cl < 2200) pre.cores in
  let (intro,intros_rating) = List.split intros in
  let (core,cores_rating) = List.split cores in
  let (prac,pracs_rating) = List.split pre.pracs in
  let (elective,electives_rating) = List.split pre.electives in
  let clubs = `List (List.map (fun club ->`String club) pre.clubs) in
  let goals = `String pre.goals in
  let int_json = fun lst -> List.map (fun lec -> `String (string_of_int lec)) lst in
  let cl_json = fun lst -> List.map (fun el -> `String ("CS " ^ string_of_int el)) lst in
  `Assoc [("name", `String pre.name);
          ("net_id", `String pre.netID);
          ("class", `String pre.year);
          ("intro", `List (cl_json intro));
          ("intros_rating", `List (int_json intros_rating));
          ("core", `List (cl_json core));
          ("cores_rating", `List (int_json cores_rating));
          ("prac", `List (cl_json prac));
          ("pracs_rating", `List (int_json pracs_rating));
          ("elective", `List (cl_json elective));
          ("electives_rating", `List (int_json electives_rating));
          ("clubs", clubs); ("goals", goals)]
) with _ -> failwith "Parsing the JSON of bot failed"

(* [json_preuser_list pres] is a JSON List of JSON formatted preusers. *)
let json_preuser_list pres =
  `List (List.map json_preuser pres)

(* [make_year ()] generates a random year for a bot-made user based on
 * year_quantities above. *)
let make_year () =
  match (Random.int (total + 1)) with
  | x when x <= List.nth year_distr 1 -> "Freshman"
  | x when x <= List.nth year_distr 2 -> "Sophomore"
  | x when x <= List.nth year_distr 3 -> "Junior"
  | _ -> "Senior"

(* [make_club ()] generates a random year for a bot-made user based on
 * club_quantities above. *)
let make_club () =
  match (Random.int 101) with
  | x when x <= List.nth club_distr 1 -> ["ACSU"]
  | x when x <= List.nth club_distr 2 -> ["WICC"]
  | x when x <= List.nth club_distr 3 -> ["URMC"]
  | x when x <= List.nth club_distr 4 -> ["Cornell Data Science"]
  | x when x <= List.nth club_distr 5 -> ["Cornell Open Source"]
  | x when x <= List.nth club_distr 6 -> ["Cornell App Development"]
  | x when x <= List.nth club_distr 7 -> ["Creative Computing Club"]
  | _ -> []

(* [make_name ()] generates a randome name for a user. A name is just a
 * random integer represetned by a string. *)
let make_name ()=
  2.**29. |> int_of_float |> Random.int |> string_of_int

(* [str_char_int i] is the string of the character of int [i]*)
let str_char_int i = i |> char_of_int |> Char.escaped

(* [rand_letter ()] generates a random letter *)
let rand_letter () =
  match Random.int 123 with
  | x when x < 97 -> (mod) x 26 |> (+) 97 |> str_char_int
  | x -> x |> str_char_int

(* [make_net_let ()] generates a random string of 3 letters. *)
let make_net_let () =
  rand_letter () ^ rand_letter () ^ rand_letter ()

(* [make_netID ()] generates a random netID composing of 3 letters and a
 * 3 digit number. *)
let make_netID () =
  make_net_let () ^ string_of_int (Random.int 1000)

(* [make_goal ()] generates a random goal for a bot-made user. *)
let make_goal () =
  match Random.int 3 with
  | 0 -> "Undecided"
  | 1 -> "Grad"
  | 2 -> "Industry"
  | _ -> failwith "Bot make_goal failed"


let intro_1 = [1110; 1112]

let intro_2 = [2110; 2112]

let crossed = [3410; 3420]

let core_classes = [2800; 3110; 4410; 4820]

let elective_classes = [4300; 4700; 4732; 4740; 4780; 4786; 5786; 2770; 4210;
                        4220; 4744; 4775; 3152; 4152; 4154; 4620; 4654; 2850;
                        4852; 4450; 2024; 2043; 4120; 4860; 2048; 3300; 4320;
                        4830; 4810; 4812; 4850; 3758; 4670; 4750; 4752; 4754;
                        4420; 5114; 5412; 5413; 5150; 5152; 5220; 5300; 5420]

let prac_classes = [4121; 4321; 4411; 4621; 4701; 4758; 5150; 5412; 5414; 5431;
                    5625; 5643]

(* [rand_select lst prob] is a list of classes that are chosen with
 * probability [1 / prob]. *)
let rand_select lst prob =
  List.filter (fun _ -> (Random.int prob) = 1) lst

(* [rand_class lst] is a list of classes that are chosen for a bot-made user
 * with equal probability 1/2. *)
let rand_class lst = rand_select lst 2

(* [rand_elec lst] is a list of classes that are chosen for a bot-made user
 * with equal probability 1/7. *)
let rand_elec lst = rand_select lst 7

(* [make_core ()] generates a random list of classes for a bot-made user. *)
let make_core () = (List.nth intro_1 (Random.int 2)) ::
                   (List.nth intro_2 (Random.int 2)) ::
                   (List.nth crossed (Random.int 2)) ::
                   rand_class core_classes

(* [make_electives ()] generates a random list of elective classes for a
 * bot-made user. *)
let make_electives () =
  rand_elec elective_classes

(* [make_prac ()] generates a random list of practicum classes for a
 * bot-made user. *)
let make_prac () =
  rand_class prac_classes

(* [make_ratings lst] generates a random list of ratings that correspond to the
 * classes in [lst]. Rating of 1 means the student disliked the material while
 * rating of 5 means the student liked the material. *)
let make_ratings lst =
  List.map (fun x -> (x, (Random.int 5) + 1)) lst

(* [make_core_ratings ()] generates the ratings for a bot-made users' core
 * classes. *)
let make_core_ratings () =
  make_ratings (make_core ())

(*[make_elec_ratings ()] generates the ratings for a bot-made users' elective
 * classes. *)
let make_elec_ratings () =
  make_ratings (make_electives ())

(* [make_prac_ratings ()] generates the ratings for a bot-made users'
 * practicum classes. *)
let make_prac_ratings () =
  make_ratings (make_prac ())

(* [make_pre_user ()] generates a random user. *)
let make_pre_user () =
  {name = make_name ();
   netID = make_netID ();
   year = make_year ();
   cores = make_core_ratings ();
   pracs = make_prac_ratings ();
   electives = make_elec_ratings ();
   clubs = make_club ();
   goals = make_goal ()}

(* [bot_list lst idx num] is a list of randomly generated pre_users made from
 * the already existing list [lst]. *)
let rec bot_list lst idx num =
  try
  if idx = num then
    lst
  else
    bot_list (make_pre_user () :: lst) (idx + 1) num
  with _ -> failwith "botlist messed up"
(*
let () =
  print_endline Sys.argv.(1);

  try
    let init = (make_pre_user () :: [])  in
    print_endline Sys.argv.(1);
    let final_bot_set = bot_list init 1 50 in
    print_endline Sys.argv.(1);
    final_bot_set |> json_preuser_list |> Yojson.to_file "bot.json"
  with _ -> failwith "Bot Failed"

let () =
  try(
    let bot_file = Gserver.get "bot.json" in
    let input_file = Gserver.get "input.json" in
    (`List ((bot_file |> to_list) @
            (input_file |> to_list))) |> Yojson.Basic.to_file "input.json"
  ) with _ -> failwith "second unit" *)
