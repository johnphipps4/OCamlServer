<?php
session_start();

    $field_fname = $_POST["fname"];
    // var_dump($field_fname);
    $field_lname = $_POST["lname"];
    // var_dump($field_lname);
    $field_net_id = $_POST['net_id'];
    // var_dump($field_net_id);
    $field_passwd = $_POST['password'];
    // var_dump($field_passwd);

//array for json
//$input_arr = array("fname" => $field_fname, "lname" => $field_lname, "net_id" => $field_net_id, "passwd" => $field_passwd);
$input_arr = array("fname"=>$field_fname,"lname"=>$field_lname,"net_id"=>$field_net_id,"passwd"=>$field_passwd);
// var_dump($input_arr);
//var_dump(json_encode($input_arr));
$login_user = $_POST['log-net_id'];
$login_pwd = $_POST['log-pwd'];

// sign them up
$_SESSION['loggedin'] = true;
$_SESSION['username'] = $field_net_id;
$_SESSION['name'] = $field_fname . " " . $field_lname;

//var_dump($_SESSION['name']);
// write the sign-up info to
$in_str = file_get_contents('login.json');
// var_dump($in_str);
$tempArray = json_decode($in_str);
// var_dump($tempArray);
array_push($tempArray,
$input_arr);
$jsonData = json_encode($tempArray);
file_put_contents('login.json', $jsonData);

header('Location: ratings.html');

// var_dump($_SESSION);
// send them to ratings info


?>
