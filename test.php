<?php

    $field_name = $_POST['name'];
    $field_net_id = $_POST['net_id'];
    $field_core = $_POST['core'];
    $field_elec = $_POST['elec'];
    $field_standing = $_POST['standing'];
    $field_post_p = $_POST['post_p'];



    $val = shell_exec("make lol");
    echo $val;
    echo "This has been made \n \n \n";
    // $json =  json_encode($json)
    // echo $json

?>
