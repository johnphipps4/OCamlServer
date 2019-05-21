open OUnit2
open Parser
open Users
open Recommender

(*******************************************************************)
(* Helper values used throughout this test suite. *)
(*******************************************************************)

let jpt86 =
  {name = "John Trujillo"; netID = "jpt86"; year = Junior;
   likes = [2800; 3110; 4850]; dislikes = [2110; 4740]; vector = Theory;
   clubs = [URMC]; goals = Grad}

let csp73 =
  {name = "Chris Pardee"; netID = "csp73"; year = Junior;
   likes = [3110; 2800]; dislikes = [2112; 1110]; vector = AI;
   clubs = []; goals = Grad}

let so339 =
  {name = "Sooyoun Oh"; netID = "so339"; year = Junior;
   likes = [3110; 4850; 4220]; dislikes = [1110; 2110; 2800; 3410]; vector = Compt;
   clubs = [WICC]; goals = Grad}

let sec295 =
  {name = "Sofie Carrillo"; netID = "sec295"; year = Junior;
   likes = [2800; 3410]; dislikes = [1110; 3110; 2110; 4740]; vector = AI;
   clubs = [URMC]; goals = Industry}

let ap666 =
  {name = "AntiChris Pardee"; netID = "ap666"; year = Junior;
   likes = [2112; 1110]; dislikes = [3110; 2800]; vector = AI;
   clubs = []; goals = Industry}

let fm23 =
  {name = "Fresh Man"; netID = "fm23"; year = Freshman;
   likes = [1110; 2110]; dislikes = [1300; 2800]; vector = PL;
   clubs = [ACSU]; goals = Undecided}

let fm232 =
  {name = "Fresh Man2"; netID = "fm232"; year = Freshman;
   likes = [1110; 2110]; dislikes = [1300; 2800]; vector = PL;
   clubs = [ACSU]; goals = Undecided}

let bdsm69 =
  {name = "Ba D Sopho More"; netID = "bdsm69"; year = Sophomore;
   likes = []; dislikes = [2800; 2110; 5150; 3110]; vector = PL;
   clubs = [WICC]; goals = Industry}

let si101 =
  {name = "Sen Ior"; netID = "si101"; year = Senior;
   likes = [4780; 2110; 1110; 2800; 4820; 4810; 3110; 4410; 3410]; dislikes = []; vector = Theory;
   clubs = [ACSU; WICC; URMC; COS]; goals = Grad}

let emt33 =
  {name = "Emp Tee"; netID = "emt33"; year = Freshman;
   likes = []; dislikes = []; vector = SWE;
   clubs = []; goals = Industry}

let all_users = [jpt86; csp73; so339; sec295; ap666; fm23; bdsm69;
                 si101; fm232; emt33] |> USet.of_list

(*******************************************************************)
(* Tests for Recommender *)
(*******************************************************************)

let like_dislike_tests = [
  "ld_jpt86"  >:: (fun _ -> assert_equal ([2800;3110;4850],[2110;4740]) (like_dislike jpt86));
  "ld_si101"  >:: (fun _ -> assert_equal ([4780; 2110; 1110; 2800; 4820; 4810; 3110; 4410; 3410],[]) (like_dislike si101));
  "ld_bdsm69" >:: (fun _ -> assert_equal ([],[2800; 2110; 5150; 3110]) (like_dislike bdsm69));
]

let get_same_tests = [
  "gs_chrises" >:: (fun _ -> assert_equal 0 (get_same csp73 ap666));
  "gs_unorder" >:: (fun _ -> assert_equal 2 (get_same bdsm69 ap666));
  "gs_sameppl" >:: (fun _ -> assert_equal 4 (get_same fm23 fm232));
  "gs_empty"   >:: (fun _ -> assert_equal 0 (get_same emt33 emt33));
]

let get_opposite_tests = [
  "go_chrises" >:: (fun _ -> assert_equal 4 (get_opposite csp73 ap666));
  "go_unorder" >:: (fun _ -> assert_equal 0 (get_opposite fm23 ap666));
  "go_sameppl" >:: (fun _-> assert_equal 0 (get_opposite fm23 fm232));
  "go_alldiff" >:: (fun _ -> assert_equal 3 (get_opposite bdsm69 si101));
  "go_empty"   >:: (fun _ -> assert_equal 0 (get_opposite emt33 emt33));
]

let get_all_tests = [
  "ga_chrises" >:: (fun _ -> assert_equal 4 (get_all csp73 ap666));
  "ga_sojpt"   >:: (fun _ -> assert_equal 8 (get_all so339 jpt86));
  "ga_sameppl" >:: (fun _-> assert_equal 4 (get_all fm23 fm232));
  "ga_nosim"   >:: (fun _ -> assert_equal 10 (get_all bdsm69 si101));
  "ga_empty"   >:: (fun _ -> assert_equal 0 (get_all emt33 emt33));
]

let common_likes_tests = [
  "cl_chrises" >:: (fun _ -> assert_equal false (common_likes csp73 ap666));
  "cl_unorder" >:: (fun _ -> assert_equal true (common_likes bdsm69 ap666));
  "cl_sameppl" >:: (fun _ -> assert_equal true (common_likes fm23 fm232));
  "cl_empty"   >:: (fun _ -> assert_equal false (common_likes emt33 emt33));
]

let common_dislikes_tests = [
  "cd_chrises" >:: (fun _ -> assert_equal true (common_dislikes csp73 ap666));
  "cd_unorder" >:: (fun _ -> assert_equal false (common_dislikes bdsm69 ap666));
  "cd_sameppl" >:: (fun _ -> assert_equal false (common_dislikes fm23 fm232));
  "cd_empty"   >:: (fun _ -> assert_equal false (common_dislikes emt33 emt33));
]

let same_vector_tests = [
  "sv_empty"  >:: (fun _ -> assert_equal true (same_vector fm232 bdsm69));
  "sv_seccsp" >:: (fun _ -> assert_equal true (same_vector sec295 csp73));
  "sv_so339"  >:: (fun _ -> assert_equal false (same_vector so339 bdsm69));
]

let same_clubs_tests = [
  "sc_exact"   >:: (fun _ -> assert_equal true (same_clubs sec295 jpt86));
  "sc_justone" >:: (fun _ -> assert_equal true (same_clubs si101 bdsm69));
  "sc_noclubs" >:: (fun _ -> assert_equal true (same_clubs emt33 ap666));
  "sc_nosim"   >:: (fun _ -> assert_equal false (same_clubs sec295 so339));
]

let same_goals_tests = [
  "sg_indus" >:: (fun _ -> assert_equal true (same_goals sec295 emt33));
  "sg_grad"  >:: (fun _ -> assert_equal true (same_goals csp73 so339));
  "sg_und"   >:: (fun _ -> assert_equal true (same_goals fm23 fm232));
  "sg_none"  >:: (fun _ -> assert_equal false (same_goals fm23 so339));
]

let tests =
  "test suite for A1"  >::: List.flatten [
    like_dislike_tests;
    get_same_tests;
    get_opposite_tests;
    get_all_tests;
    common_likes_tests;
    common_dislikes_tests;
    same_vector_tests;
    same_clubs_tests;
    same_goals_tests;
  ]

let _ = run_test_tt_main tests
