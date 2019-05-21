(******************************************************************************
   This module contains functions that will be used for implementing the posting
   functionality of our system.
 ******************************************************************************)
type web_output
(*this comes from the HTTP module -
  it's whatever our server does to decipher the user input*)

type topic =
   | General
   | Class1000s
   | Class2000s
   | Class3000s
   | Class4000s
   | OtherClasses
   | Memes

type post = {author: string;
             content: string;
             tag: topic;
             id: int}

(*[Post] represents a single post with all of its contents.*)
module type Post = sig

  (*the type of a post*)
  type t


  (*[create] takes a [web_output] and from it produces a new [Post]*)
  val create: web_output -> t
  (*NOTE: this would need to be used in some kind of "main"*)
  (*the main would be aware of the server I/O and would call Post.create
  if a certain "API Call" (HTTP request) was sent to the server to create a post*)
  (*We definitely need what's called a router in web terminology -
  something that calls functions throughout our code based on the
  HTTP request the server recieves -- not sure if this would be
  the same as the "main"*)

  (*[update_field] takes a [Post] and ['a],['b] key value pair,
    and looks for the binding of ['a] in the [Post] [t].
    If it exists, it returns a new post with ['a] bound to ['b],
    with all of the other bindings of [t] remaining the same.
    raises: [Not_found] if there is no binding of 'a in the [Post] t *)
  val update_field: t -> 'a -> 'b -> t

end

(*AF: The [Board] is a collection of [Posts]
  in order of the time they were created.
  RI: No two [pairings] may have the same id*)
module type Board = sig
  module Elt : Post

(* [elt] is the type of elements in a board. Elements in a board are posts,
 * so [elt] is just a post*)
  type elt = Elt.t

  (* [id] is the type of the ID of a post*)
  type id = int

  (* [pairing] represents searchable bindings of posts by their unique id
   * IDEA: The id is generated on the addition of the element to the [Board] *)
  type pairing = id * elt

  (* [t] is a collection of pairings -- implement however you wish*)
  type t

  (* [empty] is an empty post*)
  val empty: elt

  (*[insert t elt] takes a [t:Board] and
    a post [elt] and returns a new [Board] with [elt] added to it,
    with all previous pairings of [Board] unchanged*)
  (*NOTE: on insertion, elt is given a unique id not already in [t:Board], and
  the resulting [pairing] is inserted into [t:Board]*)
  val insert : t -> elt -> t

  (*[size t] returns the number of pairings in
    [Board] [t] of the collection of posts*)
  val size: t -> int

  (*[is_empty t] returns [true] if [Board] [t] contains no pairings,
  and [false] if it contains at least one pairing*)
  val is_empty: t -> bool

  (*[find t id] returns the [pairing] in [Board] whose elt is bound to [id]*)
  val find: t -> id -> pairing

  (*[remove t id elt] finds the post with whose
    id is [id] and returns a [Board] with all the pairings
    of [t:Board] excluding the pairing bound to [id] *)
  val remove: t -> id -> t

  (*create/insert, find, remove, choose, fold, to_list*)

  (*[choose t] returns a pairing of [t:Board]*)
  val choose: t -> pairing

  (*[fold] takes a function that performs an operation on a [pairing]
  and stores the result in an accumulator ['acc], followed by an initial
  accumulator and [t:Board]. It performs the function's operation
  on all pairings of [t:Board] and returns the result*)
  val fold: (pairing -> 'acc -> 'acc) -> 'acc -> t -> 'acc

  (*[to_list t] returns a list of all the [pairings] in [t:Board]*)
  val to_list: t -> pairing list

  (*NOTE: I think board should have an update function that calls update on a
   single post. Not sure what the type of the content that is passed along must
   be*)
  val update: t -> id -> web_output -> t
end
