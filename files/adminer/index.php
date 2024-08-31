<?php
function adminer_object() {
	//	required to run any plugin
	include_once "./plugins/plugin.php";

	//	autoloader
	foreach (glob("plugins/*.php") as $filename) {
		include_once "./$filename";
	}

	$plugins = array(
		//	specify enabled plugins here
		new AdminerDatabaseHide(array(
			"information_schema",
			"mysql",
			"performance_schema",
			"sys",
		)),
		new AdminerReadableDates(),
		#new AdminerSqlLog('sql.log'),
		new AdminerMultiTablesFilter,
	);

	return new AdminerPlugin($plugins);
}

//	include original Adminer or Adminer Editor
include "./FILE";
