(******************************************************************************
   This module contains functions that will be used for implementing the server
   with OCaml and converting data to JSON output.
 ******************************************************************************)
open Yojson
type pre_user = {name: string;
                 netID: string;
                 year: string;
                 cores: (int * int) list;
                 pracs: (int * int) list;
                 electives: (int * int) list;
                 clubs: string list;
                 goals: string}

module Gserver : sig

  (* [t] is the server *)
  type t
  (* [get t] takes the server input and returns a JSON output *)
  val get : string -> Yojson.Basic.json

  (* [delete t arg] deletes arg from [t]'s database *)
  val delete :  t -> 'a -> unit

  (* [update t arg] changes a user's values in [t]'s database' *)
  (* val update : t -> string -> 'a -> unit *)

  (*  *)
  val push: t -> Yojson.Basic.json -> unit

  val extract_user : Yojson.Basic.json -> pre_user

  val extract_user_pl : Yojson.Basic.json -> pre_user

  val get_json_by_id: Basic.json -> string -> Basic.json
end
