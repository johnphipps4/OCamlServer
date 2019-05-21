(******************************************************************************
   This module contains functions that will be used for implementing the server
   with OCaml and converting data to JSON output.
 ******************************************************************************)

module type Server = sig

  (* [t] is the server *)
  type t

(* Again, because of the lack of .mls, we have this as a placeholder for
 * preuser already defined in parser.mli *)
  type preuser

  (* [get] takes the server input and return a json object *)

  (* [get t] takes the server input and returns a JSON output *)
  val get : t -> Yojson.Basic.json

  (* [delete t arg] deletes arg from [t]'s database *)
  val delete :  t -> 'a -> unit

  (* [update t arg] changes a user's values in [t]'s database' *)
  val update : t -> 'a -> unit


end
