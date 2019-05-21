open Parser
open Gserver

(******************************************************************************)
(* Redefining types *)

type error = Exception of exn

type vector = | AI | Compt | GG | MrkNt | WebNt | PL | SWE | SysDB | Theory
              | Robot | Arch | Ren

type year = | Freshman | Sophomore | Junior | Senior

type club = | ACSU | WICC | URMC | CDS | COS | AD | CCC

type rating = int * int

type future = | Grad | Industry | Undecided

type user_result = {name: string;
                    netID: string;
                    year: year;
                    likes: int list;
                    dislikes: int list;
                    vector: vector;
                    clubs: club list;
                    goals: future;
                   }

(******************************************************************************)
(* Map for classes to corresponding vectors *)

module VClass = struct
  type t = int
  let compare = Pervasives.compare
end

module VMap = Map.Make(VClass)

let vecs =  [AI; Compt; GG; MrkNt; WebNt; PL; SWE;
             SysDB; Theory; Robot; Arch; Ren]


let all_vectors = [([4300; 4700; 4732; 4740; 4780; 4786], AI);
                   ([2770; 4210; 4220; 4744; 4775], Compt);
                   ([3152; 4152; 4154; 4620; 4654], GG);
                   ([2850; 4852], MrkNt);
                   ([4450; 5114; 5412; 5413], WebNt);
                   ([2024; 2043; 4120; 4860; 5110; 5114; 5120], PL);
                   ([2048; 5150; 5152], SWE);
                   ([3300; 4320; 4830], SysDB);
                   ([4810; 4812; 4850], Theory);
                   ([3758; 4670; 4750; 4752; 4754], Robot);
                   ([4420; 5220; 5300; 5420], Arch)]

(******************************************************************************)

let str_of_yr = function
  | Freshman  -> "Freshman"
  | Sophomore -> "Sophomore"
  | Junior    -> "Junior"
  | Senior    -> "Senior"

let str_of_vec = function
  | AI     -> "Artificial Intelligence"
  | Compt  -> "Computational Fields"
  | GG     -> "Games and Graphics"
  | MrkNt  -> "Market Networks"
  | WebNt  -> "Web Networks"
  | PL     -> "Programming Languages"
  | SWE    -> "Software Engineering"
  | SysDB  -> "Systems Databases"
  | Theory -> "Theory"
  | Robot  -> "Robotics"
  | Arch   -> "Computer Architecture"
  | Ren    -> "Renaissance"

let str_of_club = function
  | ACSU -> "ACSU"
  | WICC -> "WICC"
  | URMC -> "URMC"
  | CDS  -> "Cornell Data Science"
  | COS  -> "Cornell Open Source"
  | AD   -> "Cornell App Development"
  | CCC  -> "Creative Computing Club"


let str_of_fut = function
  | Grad      -> "Grad"
  | Industry  -> "Industry"
  | Undecided -> "Undecided"


(* [year_match s] is string [s] representing a year converted to a [year]
 * variant type. *)
let year_match = function
  | "Freshman"  -> Freshman
  | "Sophomore" -> Sophomore
  | "Junior"    -> Junior
  | "Senior"    -> Senior
  | _           -> failwith "Year Match failed"

(* [club_match s] is string [s] representing a club converted to a [club]
 * variant type. *)
let club_match = function
  | "ACSU"                    -> ACSU
  | "WICC"                    -> WICC
  | "URMC"                    -> URMC
  | "Cornell Data Science"    -> CDS
  | "Cornell Open Source"     -> COS
  | "Cornell App Development" -> AD
  | "Creative Computing Club" -> CCC
  | _                         -> failwith "Club Match failed"

(* [fut_match s] is string [s] representing a future converted to a [future]
 * variant type. *)
let fut_match = function
  | "Grad"            -> Grad
  | "Industry"        -> Industry
  | "Undecided"       -> Undecided
  | _                 -> failwith "Future Match failed"


(* [make_vec_bindings tup mp] is a mapping from class numbers to vectors. The
 * mappings are specified by [tup] and will be added to the VMap [mp]*)
let rec make_vec_bindings tup mp =
  match tup with
  | ([], _ )  -> mp
  | (h::t, v) ->
    let new_map = VMap.add h v mp in
    make_vec_bindings (t,v) new_map

(* [make_vector_map outter_lst mp] is a mapping from class numbers to vectors.
 * The bindings are made by the mappings found in [outter_lst] and [mp] is the
 * vector map that will be appended to. *)
let rec make_vector_map outter_lst mp =
  match outter_lst with
  | []     -> mp
  | h :: t -> make_vector_map t (make_vec_bindings h mp)

let vector_map = make_vector_map all_vectors VMap.empty

(* [elective_of u] is a list of all class electives of user_result [u]*)
let elective_of u = u.electives |> List.split |> fst

(* [possible_vectors lst] is a list of vectors that are determined by the
 * classes in [lst]*)
let rec possible_vectors lst =

    match lst with
    | []  -> []
    | h::t ->
    (match (VMap.find_opt h vector_map) with
      |Some x -> x :: (possible_vectors t)
      |None -> Ren :: (possible_vectors t)
    )


(* [count_occ elm lst] is the number of times [elm] occurs in list [lst]. *)
let count_occ elm lst =
  List.filter (fun x -> x = elm) lst |> List.length

(* [find_max lst] is the element of the list that occurs most frequently. *)
let find_max lst =
  List.fold_left (fun x acc -> if x > acc then x else acc) min_int lst

(* [determine_vector u] is the vector variant type determined for user_result
 * [u] based on the user's electives. *)
let determine_vector u =
  (* try *)
    let pos_vectors = possible_vectors (elective_of u) in
    let counts = List.map (fun x -> count_occ x pos_vectors) vecs in
    let zip = List.combine counts vecs in
    match List.assoc_opt (find_max counts) zip with
    | Some vec -> vec
    | None -> Ren
  (* with (e:exn) -> failwith (Printexc.to_string e) *)

let all_classes (u : pre_user) = u.cores @ u.pracs @ u.electives

(* [likes u] is a list of classes user [u] liked. *)
let likes u =
  List.filter (fun x -> (snd x) > 3) (all_classes u) |> List.map fst

(* [dislikes u] is a list of classes user [u] disliked. *)
let dislikes u =
  List.filter (fun x -> (snd x) < 3) (all_classes u) |> List.map fst

(* [make_user_result up] is a user_result [u] whose information matches [up]
 * and whose vector has been determined. *)
let make_user_result (up : pre_user) =
    {name = up.name;
     netID = up.netID;
     year = up.year |> year_match;
     likes = likes up;
     dislikes = dislikes up;
     vector = determine_vector up;
     clubs = List.map club_match up.clubs;
     goals = up.goals |> fut_match;
    }
