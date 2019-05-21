open Yojson
open Yojson.Basic.Util
open Gserver

module Parser = struct

  type t = Yojson.Basic.json

  let in_file = Gserver.get "input.json"

  let curr_user = Gserver.extract_user_pl in_file

  let j_to_string m = (Yojson.Basic.Util.to_string m) |> Yojson.to_file

  let to_json m = Yojson.Basic.from_string m

  let all_classes (u : pre_user) = u.cores @ u.pracs @ u.electives



  (****************************************************************************)

end
