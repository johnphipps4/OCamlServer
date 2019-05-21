  (******************************************************************************
   This module contains functions that will be used for customizing the content
   on the front page for each user.
 ******************************************************************************)

module type CustomBoard = sig

  (* Because we don't have .ml files, we can't refer to the types already
   * defined in other files .mli files. So, these below are all just
   * placeholders until we can actually build. *)
  type user
  type topic
  type post

  type t

  (* [empty] is an empty board *)
  val empty: t

  (* [is_empty b] is [true] if [b] is empty. *)
  val is_empty: t -> bool

  (* [insert t p] is t' if t' is the result of inserting post [p] to [t] *)
  val insert: t -> post -> t

  (* [remove t p] is t' if t' is the result of removing post [p] from [t] *)
  val remove: t -> post -> t

  (* [num_posts t] is the number of posts contained in [t] *)
  val num_posts: t -> int

  (* [get_topics u] is a list of topics specific to user [u] *)
  val get_topics: user -> topic list

  (* [get_custom_board u] is a custom board specific to user [u] *)
  val get_custom_board: user -> t

end
