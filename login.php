<?php
session_start();
$login_user = $_POST['log-net_id'];
$login_pwd = $_POST['log-pwd'];

$_SESSION['loggedin'] = true;
$_SESSION['username'] = $field_net_id;
$_SESSION['name'] = $field_fname . " " . $field_lname;


header('Location: recommendations.html');

?>
