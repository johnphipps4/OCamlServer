open String
open List
open Yojson.Basic
open Yojson.Basic.Util

(* [js_to_oc_str sr] takes a Yojson.Basic.json [sr] and returns the lowercase,
   string version of that.

   Requires: sr is a Yojson.Basic.json type that is compatible with [to_string]*)
let js_to_oc_str sr =
  (to_string sr) |> lowercase_ascii

(* [get_filename msg] takes a Yojson.Basic.json [msg] that has at least "sender"
   and "rcpt" fields of convertible type string and string list. These are
   parsed and sorted to return a filename with the lowercase usernames in
   alphabetical order.

   Requires: the "sender" field is a string and "rcpt" is a string list. *)
let get_filename msg =
  let sender = js_to_oc_str (member "sender" msg) in
  let rcpt = (member "rcpt" msg) |> to_assoc |> List.split |> snd in
  let rcpts = List.map js_to_oc_str rcpt in
  let sr = List.sort_uniq Pervasives.compare (sender :: rcpts) in
  let flnm = List.fold_left (fun fl nms -> fl ^ "_" ^ nms) (hd sr) (tl sr) in
  "./messaging/" ^ flnm ^ ".json"

(* [get_convo_file msg] takes in a Yojson.Basic.json [msg] and tries to open
   the json file associated with the conversation. If it doesn't exist, make
   one corresponding to the filename computed in [get_filename], then open it.
   The fields in the json of the conversation are "displ" for the past few
   string messages sent in the conversation in a list (defaulted to 5 messages)
   and "oldconvo" for the rest of the conversation, also in a string list.

   Requires: [msg] has at least the fields as defined in get_filename. *)
let rec get_convo_file msg =
  let filename = get_filename msg in
  try
     from_file filename
   with
     Sys_error err_msg ->
     let skel = `Assoc [ ("displ", `List []) ; ("oldconvo", `List []) ] in
       to_file filename skel; from_file filename

(* [displ5 displ oc] takes in two lists, [displ] and [oc] and returns the first
   five elements of [displ] as a list in the first part of a tuple, and returns
   the rest of [displ] appended to [oc] in the second part of the tuple. If
   there are less than five elements in [displ], [displ] and [oc] are the
   first and second elements of the tuple.

   Requires: [displ] and [oc] are lists of the same type. *)
let rec displ5 displ oc =
  match displ with
  |e1::e2::e3::e4::e5::t -> (e1::e2::e3::e4::[e5], t @ oc)
  |lst -> (lst, oc)

(* [log_msg msg] takes in a Yojson.Basic.json [msg], with the fields defined in
   [get_filename] and a "msg" field of a string, and either opens or creates
   the past message files in a .json format to be able to add the "msg" value
   to the displ field of a conversation.
   This function forces the length of the string list in "displ" to be 5.

   Requires: [msg] to have string field "sender", string list field "rcpt",
   and string "msg". *)
let log_msg msg =
  let convo = get_convo_file msg in
  let sender = js_to_oc_str (member "sender" msg) in
  let message = sender ^ ": " ^ ((member "msg" msg) |> to_string) in
  let displ = (member "displ" convo) |> to_list in
  let oldconvo = (member "oldconvo" convo) |> to_list in
  let new_displ = (`String message) :: displ in
  let (dis,oc) = displ5 new_displ oldconvo in
  let new_contents = `Assoc [("displ", `List dis) ; ("oldconvo", `List oc)] in
  to_file (get_filename msg) new_contents; print_endline (get_filename msg)

(* [display_more srjson] takes in Yojson.Basic.json [srjson] of just the fields
   specified in [get_filename], and gets the conversation json associated with
   them. It then appends the list in "displ" to the previous 5 messages before
   the ones in "displ" already.
   This modifies the conversation json file itself, and "displ"'s list's length
   is variable. This is defaulted to 5 when logging in another message.

   Requires: [srjson] to have string field "sender" and string list field
   "rcpt". *)
let display_more srjson =
  let convo = get_convo_file srjson in
  let displ = (member "displ" convo) |> to_list in
  let oldconvo = (member "oldconvo" convo) |> to_list in
  let (old5,nold) = displ5 oldconvo [] in
  let new_contents = `Assoc [("displ", `List (displ @ old5)) ;
                             ("oldconvo", `List nold)] in
  to_file (get_filename srjson) new_contents;
                                 print_endline (get_filename srjson)

(* This calls [log_msg] on a json with nonempty "msg" field in "test.json".
   It does not do anything for those with an empty "msg" field.

   Requires: the json in "test.json" has string field "sender",
   string list field "rcpt", and string "msg". *)
let () = let ff = from_file "messaging/test.json" in
  if ((member "msg" ff) |> to_string = "") then display_more ff else log_msg ff
