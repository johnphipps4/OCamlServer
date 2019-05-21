<?php
session_start();

if (isset($_SESSION['loggedin']) && $_SESSION['loggedin'] == true) {
$user_name= $_SESSION['username'];
$name = $_SESSION['name'];

$class = $_POST['radio'];
 //var_dump($name);
 //var_dump(json_encode($_POST));
$intro = $_POST['checkbox'];
 //echo "intro";
 // var_dump($intro);
$core = $_POST['checkbox1'];
 //echo "core";
 //var_dump($core);

 //var_dump($elec);
$prac = $_POST['checkbox2'];

$elec = $_POST['checkbox3'];
 //var_dump($prac);
$clubs = $_POST['checkbox4'];
 //var_dump($clubs);
$goals = $_POST['radio1'];
 //var_dump($goals);
 //$goals = "squadgoals";

function filter($arr) {
   $new_arr = [];
   $count = 0 ;
     foreach($arr as $x){
       if ($x <> ""){
         $new_arr[$count] = $x;
         $count = $count + 1;
       }
     }
     return $new_arr;
}

$intros_rating = filter($_POST['intros']);
//var_dump(json_encode($intros_rating));
$cores_rating = filter($_POST['cores']);
//var_dump(json_encode($cores_rating));
$pracs_rating = filter($_POST['pracs']);
//var_dump(json_encode($pracs_rating));
$electives_rating = filter($_POST['elecs']);

$in_arr = array("name" => $name, "net_id" => $user_name, "class" => $class, "intro" => $intro, "intros_rating" => $intros_rating, "core" => $core, "cores_rating" => $cores_rating, "elective" => $elec, "electives_rating" => $electives_rating, "prac" => $prac, "pracs_rating" => $pracs_rating, "clubs" => $clubs, "goals" => $goals);
//{"name":"173259403","net_id":"qma861","class":"Sophomore","intro":["CS 1112","CS 2110","CS 3420","CS 3110"],"intros_rating":["4","1","2","1"],"core":[],"cores_rating":[],"prac":["CS 4121","CS 4621","CS 4758","CS 5414","CS 5431","CS 5625","CS 5643"],"pracs_rating":["5","5","4","2","2","4","1"],"elective":["CS 4780","CS 2850","CS 4450","CS 2024","CS 2043","CS 4120","CS 4860","CS 2048","CS 4810","CS 4420"],"electives_rating":["4","5","1","1","3","2","3","1","3","5"],"clubs":["WICC"],"goals":"Undecided"}
//var_dump(($in_arr));

$in_str = file_get_contents('input.json');
$tempArray = json_decode($in_str);
//var_dump($tempArray);

array_push($tempArray, $in_arr);
$jsonData = json_encode($tempArray);
//var_dump($jsonData);
file_put_contents('input.json', $jsonData);
header('Location: recommendations.html');

}
else
{
 $user_name= $_SESSION['username'];
 var_dump($_SESSION);
 echo $user_name;
 header("Location: index.html");
}


?>
