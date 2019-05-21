open Gserver
open Users
open Yojson
open Yojson.Basic.Util

module type UserMod = sig
    type t
    val compare: t -> t -> int
  end

module UserMod = struct
  type t = user_result
  let compare u1 u2 =
    String.compare u1.netID u2.netID
end

module type ClassMod = sig
  type t
  val compare: t -> t -> int
end

module ClassMod = struct
  type t = int
  let compare i1 i2 =
    Pervasives.compare i1 i2
end

module USet = Set.Make(UserMod)

module CSet = Set.Make(ClassMod)

(**************************************************************************)
let all_users =
(* try *)
  let pre_lst = let mmm= Gserver.get("input.json") in print_endline (Yojson.Basic.to_string mmm);
  to_list mmm |> List.map Gserver.extract_user |> List.map make_user_result in
   USet.of_list pre_lst
(* with _ -> failwith "BLARKSON" *)
(**************************************************************************)


(* [u_crd a] is the cardinality of user set [a] *)
let u_crd a = USet.cardinal a

(* [c_crd a] is the cardinality of class set [a] *)
let c_crd a = CSet.cardinal a

(* [u_crd_flt a] is the cardinality of user set [a] as a float *)
let u_crd_flt a = u_crd a |> float_of_int

(* [c_crd_flt a] is the cardinality of user set [a] as a float *)
let c_crd_flt a = c_crd a |> float_of_int


(* [jcc_idx a b] is the Jaccardian index of users [a] and [b] *)
let jcc_idx a b =
  USet.inter a b |> u_crd_flt |> (/.) (USet.union a b |> u_crd_flt)

let like_dislike = function
  | {name = _; netID = _; likes = l; dislikes = d;
     vector = _; clubs = _; goals = _;} -> (l, d)

let get_class_set u =
  let (l, d) = like_dislike u in
  ((l |> CSet.of_list), (d |> CSet.of_list))

let get_same u1 u2 =
  let (l1, d1) = get_class_set u1 in
  let (l2, d2) = get_class_set u2 in
  CSet.inter l1 l2 |> c_crd |> (+) (CSet.inter d1 d2 |> c_crd)

let get_opposite u1 u2 =
  let (l1, d1) = get_class_set u1 in
  let (l2, d2) = get_class_set u2 in
  CSet.inter l1 d2 |> c_crd |> (+) (CSet.inter l2 d1 |> c_crd)

let get_all u1 u2 =
  let (l1, d1) = get_class_set u1 in
  let (l2, d2) = get_class_set u2 in
  CSet.union l1 l2 |> CSet.union d1 |> CSet.union d2 |> c_crd

let similarity_idx u1 u2 =
  let numerator = get_same u1 u2 - (get_opposite u1 u2) in
  numerator |> float_of_int |> (/.) (get_all u1 u2 |> float_of_int)

let common_likes u1 u2 = get_same u1 u2 > 0

let common_dislikes u1 u2 = get_opposite u1 u2 > 0

let same_vector u1 u2 = u1.vector = u2.vector

let size_filtered_lst lst f =
  (lst |> List.filter f |> List.length) > 0

let same_clubs u1 u2 =
  if (u1.clubs = [] && u2.clubs = []) then true else
    size_filtered_lst u2.clubs (fun x -> List.mem x u1.clubs)

let same_goals u1 u2 = u1.goals = u2.goals

(* [filter_users u f u_set] is user set [u_set] with users who satisfy the
 * predicate specified by applying f to the user and user [u]. *)
let filter_users u f u_set =
  USet.filter (fun x -> (f u x)) u_set

let users_w_same_likes u = filter_users u common_likes all_users

let users_w_same_dislikes u = filter_users u common_dislikes all_users

let users_w_same_vector u = filter_users u same_vector all_users

let users_w_same_clubs u = filter_users u same_clubs all_users

let users_w_same_goals u = filter_users u same_goals all_users

let possible_matches_list u =
  [users_w_same_likes u; users_w_same_dislikes u; users_w_same_vector u;
   users_w_same_clubs u; users_w_same_goals u]

(* [refine_user_list u f init] is the result of applying f to all possible
 * matches of user [u]. *)
let refine_user_list u f init =
  List.fold_left f init (u |> possible_matches_list )

let possible_matches u =
  refine_user_list u (fun x acc -> USet.union x acc) USet.empty

let users_just_like_u u =
  refine_user_list u (fun x acc -> USet.inter x acc) (USet.singleton u)

let get_mentors u =
  filter_users u (fun u x -> (x.year = Junior || x.year = Senior))
    (users_w_same_vector u)

let mentors (u : user_result) =
  if u.year = Senior then USet.empty else
    get_mentors u

let recommended_classes u =
  let tup_lst = List.filter (fun (x,y) -> y = u.vector) all_vectors in
  if tup_lst = [] then
    CSet.empty
  else
    let all_classes = tup_lst |> List.hd |> fst |> CSet.of_list in
    CSet.diff all_classes (CSet.of_list u.likes)


let final_matches u =
  USet.filter (fun x -> similarity_idx u x > 0.5) (possible_matches u)

(****************************************************************************)

(* [wrap_likes ur] is a list of classes that user [ur] likes converted from
 * ints to JSON `String. *)
let wrap_likes ur =
  List.map (fun x -> `String (x |> Pervasives.string_of_int)) ur.likes

(* [wrap_dislikes ur] is a list of classes that user [ur] dislikes converted
 * from ints to JSON `String. *)
let wrap_dislikes ur =
  List.map (fun x -> `String (x |> Pervasives.string_of_int)) ur.dislikes

(* [wrap_clubs ur] is a list of clubs that user [ur] is in converted from
 * club variant types to JSON `Stirng. *)
let wrap_clubs ur =
  List.map (fun x -> `String (x |> str_of_club)) ur.clubs

(* [make_person_json ur] is a user_result [ur] transformed into JSON format. *)
let make_person_json ur =
  try(
  `Assoc [("NetID", `String ur.netID);
          ("Name", `String ur.name);
          ("Year", `String (ur.year |> str_of_yr));
          ("Likes", `List (ur |> wrap_likes));
          ("Dislikes", `List (ur |> wrap_dislikes));
          ("Vector", `String (ur.vector |> str_of_vec));
          ("Clubs",`List (ur |> wrap_clubs));
          ("Goals", `String (ur.goals |> str_of_fut));
         ]
) with _ -> failwith "make person json failed"

(* [make_class_json cls_lst] is a list of classes wrapped into JSON Strings. *)
let make_class_json cls_lst =
  List.map (fun x -> `String (x |> Pervasives.string_of_int)) cls_lst

(* [json_classes ur] is a JSON List of classes written to an output file. *)
let json_classes ur =
  (`List (ur |> recommended_classes |> CSet.elements |> make_class_json))
   |> Yojson.to_file "output.json"

(* [make_set_json u_set] is a JSON list of JSON formatted users in [u_set]. *)
let make_set_json u_set =
  `List (List.map make_person_json (u_set |> USet.elements))

(* [json_set_make ur f] is the set of users [ur] filtered by function [f] and
 * turned into a JSON then written to an output file. *)
let json_set_make ur f =
  ur |> f |> make_set_json |> Yojson.to_file "output.json"

(* [json_set_likes ur] is the JSON set of users with same likes as [ur]. *)
let json_set_likes ur =
    json_set_make ur users_w_same_likes

(* [json_set_dislikes ur] is the JSON set of users with the same dislikes as
 * [ur]. *)
let json_set_dislikes ur =
  json_set_make ur users_w_same_dislikes

(* [json_set-vector ur] is the JSON set of users with the same vector as [ur].
 *)
let json_set_vector ur =
  json_set_make ur users_w_same_vector

(* [json_set_goals ur] is the JSON set of users with the same goal as [ur].  *)
let json_set_goals ur =
  json_set_make ur users_w_same_goals

(* [json_set_clubs ur] is the JSON set of users in the same clubs as [ur]. *)
let json_set_clubs ur =
  json_set_make ur users_w_same_clubs

(* [json_set_mentors ur] is the JSON set of users who could be a mentor to
   [ur]. *)
let json_set_mentors ur =
  json_set_make ur mentors

let () =
    (* Getting information *)
    let netid = Sys.argv.(2) in
    let json = Gserver.get("input.json") in

    (* Get users to compare to current user *)
    let usrlt = (Gserver.get_json_by_id json netid) |>
                Gserver.extract_user  |> Users.make_user_result in

    (* Determine which field the user clicked on and return results*)
    match Sys.argv.(1) with
    |"likes" -> json_set_likes usrlt
    |"dislikes" -> json_set_dislikes usrlt
    |"vector" -> json_set_vector usrlt
    |"goals" -> json_set_goals usrlt
    |"clubs" -> json_set_clubs usrlt
    |"classes" -> json_classes usrlt
    |"mentors" -> json_set_mentors usrlt
    | _ -> failwith "invalid"
