<?php

/** Use filter in tables list
* @link https://www.adminer.org/plugins/#use
* @author Jakub Vrana, https://www.vrana.cz/
* @license http://www.apache.org/licenses/LICENSE-2.0 Apache License, Version 2.0
* @license http://www.gnu.org/licenses/gpl-2.0.html GNU General Public License, version 2 (one or other)
*/
class AdminerTablesFilter {
	function tablesPrint($tables) {
		?>
<p class="jsonly">
<input type="search" id="filter-field" placeholder="Filter"
	onkeyup="tablesFilterInput()" autocomplete="off" />
<button id="filter-reset" onclick="resetFilter()">X</button>
</p>
<ul id="tables">
<?php
		$active = trim(empty($_GET["select"])
			? (empty($_GET["table"]) ? '' : $_GET["table"])
			: $_GET["select"]);

		foreach ($tables as $table => $type) {
			$n = h($table);
			$s = ($table == $active) ? ' class="active"' : '';
			$h = h(ME);
			$u = urlencode($table);
			?>
<li data-table-name="<?= $n ?>"><div<?= $s ?>>
<a href="<?= $h ?>select=<?= $u ?>" title="Select data">&equiv;&equiv;</a>
<a href="<?= $h ?>table=<?= $u ?>" title="Table structure"><?= $n ?></a>
</div></li>
<?php
		}
		?>
</ul>
<style type="text/css">
#menu {
	height			: calc(100% - 2rem);
	padding			: 0;
}
#tables {
	position		: absolute;
	width			: calc(100% - 1em);
	height			: calc(100% - 9rem);
	overflow-y		: scroll;
	padding			: 0 0 0 1em;
	margin			: 0;
}
#tables a {
	font-weight		: normal;
	background		: transparent;
}
#tables a:hover {
	text-decoration	: none;
}
#tables .active {
	background		: rgba(221,221,255,1);
}
#tables > :hover {
	background		: rgba(0,0,0,.1);
}
#filter-field {
	width			: 90%;
	height			: 2em;
	background		: rgba(0,0,0,.03);
	border			: none;
	padding			: 4px;
}
#filter-reset {
	float			: right;
	width			: 10%;
	height			: 2em;
	background		: rgba(0,0,0,.03);
	border			: none;
	padding			: 1px 0;
}
</style>
<script type="text/javascript">
var tablesFilterTimeout = null;
var tablesFilterValue = '';

function tablesFilter(){
	var value = document.getElementById('filter-field').value.toLowerCase();
	if (value == tablesFilterValue) {
		return;
	}
	tablesFilterValue = value;
//	if (value != '') {
//		var reg = (value + '').replace(/([\\\.\+\*\?\[\^\]\$\(\)\{\}\=\!\<\>\|\:])/g, '\\$1');
//		reg = new RegExp('('+ reg + ')', 'gi');
//	}
	if (sessionStorage) {
		sessionStorage.setItem('adminer_tables_filter', value);
	}
	var tables = document.getElementById('tables').getElementsByTagName('li');
	for (var i = 0; i < tables.length; i++) {
		var a = tables[i].getElementsByTagName('a')[1];
		var text = tables[i].getAttribute('data-table-name');
		if (value == '') {
			tables[i].className = '';
			a.innerHTML = text;
		} else {
//			tables[i].className = (text.toLowerCase().indexOf(value) == -1 ? 'hidden' : '');
//			a.innerHTML = text.replace(reg, '<b>$1</b>');
			tables[i].classList[keywords(a,text,value)]('hidden');
		}
	}
}

function keywords(a,l,v) {		//	tag A, label, value
	var h = 0, c = 0, m = l;	//	not lowercased
	v.split(",").forEach(function(w){
		w = w.replace(/\W/g,'');	//	word
		if (w.length) {				//	skip empties
			if (l.toLowerCase().indexOf(w) < 0) h++;
			m = m.replace(w,'<u>'+ w +'</u>');
			c++;
		}
	});
	a.innerHTML = m;
	return h == c ? 'add' : 'remove';
}

function resetFilter() {
	tablesFilterValue = '-';
	document.getElementById('filter-field').value = '';
	tablesFilter();
}

function tablesFilterInput() {
	window.clearTimeout(tablesFilterTimeout);
	tablesFilterTimeout = window.setTimeout(tablesFilter, 200);
}

if (sessionStorage){
	var db = document.getElementById('dbs').getElementsByTagName('select')[0];
	db = db.options[db.selectedIndex].text;
	if (db == sessionStorage.getItem('adminer_tables_filter_db') && sessionStorage.getItem('adminer_tables_filter')){
		document.getElementById('filter-field').value = sessionStorage.getItem('adminer_tables_filter');
		tablesFilter();
	}
	sessionStorage.setItem('adminer_tables_filter_db', db);
}
</script>
<?php
		return true;
	}
}
