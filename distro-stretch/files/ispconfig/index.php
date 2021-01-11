<?php
	//	redirect to the https port of ispconfig
	$server = $_SERVER["SERVER_NAME"];
	header("location: https://$server:8080");
