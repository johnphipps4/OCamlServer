<?php
  session_start();
  // var_dump($_SESSION['username']);
  echo "<html><head><meta charset='UTF-8'>";
  echo "<title>Messaging Form</title>";
  echo "<link href='https://fonts.googleapis.com/css?family=Titillium+Web:400,300,600' rel='stylesheet' type='text/css'>";
  echo "<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/normalize/5.0.0/normalize.min.css'>";
  echo "<link rel='stylesheet' href='../css/style.css'></head>";
  echo "<table style='width:75%' align='center'><tr align='center'>";
  echo "<td><br><h1>Messages</h1></a></td></table>";
  echo "<header style='height: 100px; background: #262626'></header>";
  echo "<table style='width:75%' align='center'><tr align='center'>";
  echo "<td><a href= 'index.html'><h2>Message Other People</h2></a></a></td>";
  echo "<td><a href= '../recommendations.html'><h2>Go Back to Recommendations</h2>";
  echo "</a></a></td></tr></table><br><br>";
  echo "<body style= 'background: #262626; background-repeat: no-repeat; background-size:cover'>";
  $sender = $_SESSION['username'];
  $rc = $_POST["recip_id"];
  $rcpt = explode(", ",$rc);
  $msg = $_POST["msg"];

  if ((isset($_POST['Send_Message'])) and ($msg == "")) {
    ;
  }

else {
  if(isset($_POST['Get_Previous_5_Messages'])) {
    $msg = "";
  }
  $post_data = array('sender' => $sender, 'rcpt' => $rcpt, 'msg' => $msg);

  $myJSON = json_encode($post_data, JSON_FORCE_OBJECT);

  $myfile = fopen("test.json", "w") or die("Unable to open file!");
  fwrite($myfile, $myJSON);
  fclose($myfile);

  chdir('..');
  $op = shell_exec("make msg");
  $msg_file = trim (substr($op, strrpos ($op,"/messaging") + 11));
  $convo = json_decode(file_get_contents($msg_file,true), $assoc = true);
  $displayed = $convo["displ"];
  for($i=count($displayed)-1; $i>=0; $i--){
    if ((strpos($displayed[$i],$sender) == 0) and (strpos($displayed[$i],$sender) !== false)) {
      echo "<font color='white'
      style='padding-left:700px'
      size='5'>".$displayed[$i]."</font><br>";
    }
    else {
      echo "<font color='red'
      style='padding-left:700px'
      size='5'>".$displayed[$i]."</font><br>";
    }
  }
}

  echo "<br><br><form action='messaging.php' method='post'>";
  echo "<td><input type='hidden' name='sender_id' value='".$sender."'></td>";
  echo "<td><input type='hidden' name='recip_id' value='".$rc."'></td></tr>";
  echo "<table style='width:75%' align='center'><tr align='center'>";
  echo "<th><label><span style='color:white'>Message: </span></label></th>";
  echo "</tr><br><tr align='center'><td><input type='text' name='msg'></td>";
  echo "</tr></table><br><table style='width:75%' align='center'>";
  echo "<tr align='center'>";
  echo "<td><input type='submit' name='Send Message'
        value='Send Message'></button>";
  echo "</button></td><td><input type='submit' name='Get Previous 5 Messages'
  value='Get Previous 5 Messages'>";
  echo "</td></tr></table><br><br></form></div></div></body></html>";
?>
