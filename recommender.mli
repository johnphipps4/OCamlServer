open Parser
open Users

(******************************************************************************
   This module contains functions that recommmend users to
   each other based on their individual and collective data.
 ******************************************************************************)

module type UserMod = sig
  type t
  val compare: t -> t -> int
end

module type ClassMod = sig
  type t
  val compare: t -> t -> int
end

module CSet : Set.S with type elt = int
module USet : Set.S with type elt = user_result


(* [like_dislike u] is the tuple of a user's [u] liked and disliked classes in
 * the form (l, d). *)
val like_dislike: user_result -> int list * int list

(* [get_class_set u] is a tuple of the set of classes of user [u] in the form
 * (likes, dislikes) *)
val get_class_set: user_result -> CSet.t * CSet.t


(* [get_same u1 u2] is the number of classes that users [u1] and [u2] have in
 * common in terms of both likes and dislikes. *)
val get_same : user_result -> user_result -> int

(* [get_opposite u1 u2] is the number of classes that users [u1] and [u2]
 * completely disagree on. *)
val get_opposite : user_result -> user_result -> int

(* [get_all u1 u2] is the total combined number of classes that users [u1] and
 * [u2] have taken. *)
val get_all : user_result -> user_result -> int

(* [similarity_idx u1 u2] is a number in the range [-1, 1] that measures the
 * similarity of users [u1] and [u2] on their liked / disliked classes. An
 * index of -1 represents complete uncompatbility where as an index of 1
 * represents complete compatibility. *)
val similarity_idx : user_result -> user_result -> float

(* [common_likes u1 u2] is [true] if users [u1] and [u2] have at least one class
 * in common that they both like. *)
val common_likes : user_result -> user_result -> bool

(* [common_dislikes u1 u2] is [true] if users [u1] and [u2] have at least one
 * class in common that they both dislike. *)
val common_dislikes : user_result -> user_result -> bool

(* [same_vector u1 u2] is [true] if users [u1] and [u2] have the same vector. *)
val same_vector : user_result -> user_result -> bool

(* [size_filtered_lst lst f] is [true] if [lst] after it has been filtered by
 * a predicate specified by function f is nonempty. *)
val size_filtered_lst : 'a list -> ('a -> bool) -> bool

(* [same_clubs u1 u2] is [true] if users [u1] and [u2] are in at least one
 * same club together. If the two users are not in any clubs, this is true. *)
val same_clubs : user_result -> user_result -> bool

(* [same_goals u1 u2] is [true] if users [u1] and [u2] have the same goals. *)
val same_goals : user_result -> user_result -> bool

(* [users_w_same_likes u] is a subset of all users who also like the same
 * classes as user [u]. *)
val users_w_same_likes : user_result -> USet.t

(* [users_w_same_dislikes u] is a subset of all users who also dislike the same
 * classes as  user [u]. *)
val users_w_same_dislikes : user_result -> USet.t

(* [users_w_same_vector u] is a subset of all users who have the same vector as
 * user [u]. *)
val users_w_same_vector : user_result -> USet.t

(* [users_w_same_clubs u] is a subset of all users who have the same vector as
 * user [u]. *)
val users_w_same_clubs : user_result -> USet.t

(* [users_w_same_goals u] is a subset of all users who have the same goals as
 * user [u]. *)
val users_w_same_goals : user_result -> USet.t

(* [possible_matches u] is the set of all users who are possible matches for
 * user [u]. *)
val possible_matches : user_result -> USet.t

(* [users_just_like_u u] is the set of users who have the same qualities as
 * user [u] in terms of class likes, class dislikes, vectors, clubs, and
 * goals. *)
val users_just_like_u : user_result -> USet.t

(* [get_mentors u] is the set of users who are eligible to mentor user [u]. A
 * mentor is someone who has the same vector as user [u] and is an
 * upperclassmen.*)
val get_mentors : user_result -> USet.t

(* [mentors u] is the set of users who are eligible to mentor user [u]. A
 * mentor is someone who has the same vector as user [u] and is an
 * upperclassmen. If user [u] is a senior, [mentors u] is empty.*)
val mentors : user_result -> USet.t

(* [recommended_classes u] is a set of all classes that are recommended for
 * user [u] based on the user's vector. *)
val recommended_classes : user_result -> CSet.t

(* [final_matches u] is the set of all users who are final matches for user [u].
 * A final match is a user who has a similarity index above a certain threshold.
 *)
val final_matches : user_result -> USet.t

(* [make_set_json uset] is a json made from a set of users. *)
val make_set_json : USet.t -> Yojson.json
