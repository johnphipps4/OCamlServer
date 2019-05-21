<?php
    header("Access-Control-Allow-Origin *");
    session_start();
    //var_dump($_SESSION['username']);
    if(isset($_SESSION['loggedin']) && $_SESSION['loggedin'] == true){

    $user_name = $_SESSION['username'];
    //var_dump($user_name);
    $testdata = $_POST['data_type']; //I can just pass this to ocaml
    $cmd = ("ocamlbuild -use-ocamlfind -pkg cohttp-lwt-unix -pkg yojson -pkg nocrypto recommender.byte && ./recommender.byte \"$testdata\" \"$user_name\"");


    //var_dump($cmd);
    shell_exec($cmd);
    echo file_get_contents("output.json");
    //echo $user_name;
    }
    else{
      $user_name = $_SESSION['username'];
      echo "you are not logged in";
      echo $user_name;
      header("Location: ratings.html");
    }

?>
