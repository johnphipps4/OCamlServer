
open Yojson
open Yojson.Basic.Util
open Printf
(* open Str
open Cohttp_lwt
open Lwt
open Cohttp_lwt_unix
open Cohttp *)


type pre_user = {name: string;
                 netID: string;
                 year: string;
                 cores: (int * int) list;
                 pracs: (int * int) list;
                 electives: (int * int) list;
                 clubs: string list;
                 goals: string}



module Gserver = struct

  type t = string

  (*  *)
  let get i = Yojson.Basic.from_file i

  (*  *)
  let delete f j :unit = failwith "unimplemented"

  let push f j = Yojson.Basic.to_file f j

  let extract = List.map (fun (r,y) ->
              (r,Yojson.Basic.Util.to_string y))

  let class_to_int class_string =
    (String.sub class_string 3 4) |> int_of_string

  let classes_with_ratings cs rs =
    let classes = List.map (fun c -> c |> to_string |> class_to_int)
                                                         (to_list cs) in
    let rts = List.filter (fun r -> String.length (to_string r) = 1)
                                                         (to_list rs) in
    let ratings = List.map (fun rt -> rt |> to_string |> int_of_string) rts in
    List.map2 (fun ra cl -> (cl,ra)) ratings classes

  let extract_core x = x |> to_list |> List.map (member "cores") |> List.map to_string

  let extract_core_r x = x |> to_list |> List.map (member "cores_rating") |> List.map to_string

  let extract_user json =
    {name = json |> member "name" |> to_string;
     netID = json |> member "net_id" |> to_string;
     year  = json |> member "class" |> to_string;
     cores = (classes_with_ratings (member "core" json)
                (member "cores_rating" json)) @
             (classes_with_ratings (member "intro" json)
                (member "intros_rating" json));
     pracs = classes_with_ratings (member "prac" json)
                      (member "pracs_rating" json);
     electives = classes_with_ratings (member "elective" json)
                                   (member "electives_rating" json);
     clubs = List.map (fun x -> x|> to_string)
                                      (json |> member "clubs" |> to_list);
     goals = json |>  member "goals" |> to_string }

  let get_json_by_id json (cornell_email:string)  =
    let result =  json |> to_list |> List.filter
                    (fun e -> (to_assoc e |> List.assoc "net_id") = `String cornell_email) in
    match result with
    | []    -> failwith "that user doesn't exist"
    | h::[] -> h
    | _  -> failwith "there's more than one user"

  let extract_user_pl (json : Yojson.Basic.json) =
    json |> to_list |> List.rev |> List.hd |> extract_user


  (* partial function  *)
  (* let extract_c json = [json] |> Yojson.Basic.Util.flatten |> Yojson.Basic.Util.filter_assoc |> List.hd |> List.map (fun (k,v) -> (k, Yojson.Basic.Util.to_assoc v))
  |> List.hd |> snd |> List.map snd

  let extract_class_pl (json : Yojson.Basic.json)  =
    let ccpc=  extract_c json |> Yojson.Basic.Util.filter_list |> List.map (List.map (fun y -> Yojson.Basic.Util.to_string y)) in
    let y_ccpc = extract_c json |> Yojson.Basic.Util.filter_string
    in y_ccpc :: ccpc

  (* gets all the people *)
   let extract_class (json : Yojson.Basic.json)  =
      List.map extract_class_pl [json]

  let class_to_int s =
  String.sub s 3 4 |> int_of_string *)


  let update (f: string) (j:Basic.json) =
    delete f j;
    push f j

  (*  *)
  let encrypt x = Nocrypto.Rsa.encrypt x

  let decrypt x = Nocrypto.Rsa.decrypt x


  (* let valid pwd i =
    try
    (match (List.assoc "passwd" i = pwd) with
    | true -> "true"
    | _ -> "false")
    with _ -> "false"


  (* let () = print_endline (valid Sys.argv.(1) (extract_user_pl (get Sys.argv.(2))))

  (* let get_class_S () =
    print_endline (Recommender.get_c
                     (Parser.make_user_result
                        (Sys.argv.(1)|> get |> extract_user_pl))) *)
     let print x = print_endline x *) *)
end
