(******************************************************************************
   This module contains functions that organize the users of
   our site.
 ******************************************************************************)
open Parser
open Gserver

(* A [year] is a variant type representing the current class standing of
  a student.*)
type year = | Freshman | Sophomore | Junior | Senior


(* A [vector] is a variant type representing the academic interest of
  a student. *)
type vector = | AI | Compt | GG | MrkNt | WebNt | PL | SWE | SysDB | Theory
              | Robot | Arch | Ren

(* A [club] is a variant type representing a club that a student may participate
 * in. *)
type club = | ACSU | WICC | URMC | CDS | COS | AD | CCC

(* A [rating] is a tuple of ints of the form (class, ranking) where a class is
 * identified by its class number and a ranking is an int in the range [1,5]
 * corresponding to [Hated class, Loved class]*)
type rating = int * int

(* A [future] is a variant type representing the future aspirations of a
 * student. *)
type future = | Grad | Industry | Undecided

(* A [user_result] is a student with a name, netID, year, liked classes,
 * disliked classes, a vector, clubs, and goals. *)
type user_result = {name: string;
                    netID: string;
                    year: year;
                    likes: int list;
                    dislikes: int list;
                    vector: vector;
                    clubs: club list;
                    goals: future;
                   }

(* [all_vectors] is a mapping of classes to a vector. *)
val all_vectors: (int list * vector) list

(* [str_of_yr y] is year [y] converted to a string. *)
val str_of_yr: year -> string

(* [str_of_vec v] is vector [v] converted to a string. *)
val str_of_vec: vector -> string

(* [str_of_club c] is club [c] converted to a string. *)
val str_of_club: club -> string

(* [str_of_fut f] is future [f] converted to a string. *)
val str_of_fut: future -> string

(* [make_user_result pu] takes a pre_user [pu] and makes a user_result [ur].
 * user_results contain all the same information as pre_users except that
 * user_results have vectors calculated and classes separated into likes and
 * dislikes. *)
val make_user_result: pre_user -> user_result
