<?php

/** Use filter in tables list
* @link https://www.adminer.org/plugins/#use
* @author Jakub Vrana, https://www.vrana.cz/
* @editor Luigi Cocconcelli k-adminer@rete.us
* @license https://www.apache.org/licenses/LICENSE-2.0 Apache License, Version 2.0
* @license https://www.gnu.org/licenses/gpl-2.0.html GNU General Public License, version 2 (one or other)
*/
class AdminerMultiTablesFilter {
	function tablesPrint($tables)
	{
		?>
<script <?php echo nonce(); ?>>
var
TO = null,	//	timeout value
FV = '';	//	filter value

function keywords(a,n,v) {		//	tag A, name, value
	var h = 0, c = 0, m = n;	//	not lowercased
	v.split(/\W/).forEach(function(w){
		w = w.replace(/\W/g,'');	//	word
		if (w.length) {				//	skip empties
			if (n.toLowerCase().indexOf(w) < 0) h++;
			m = m.replace(w,'<u>'+ w +'</u>');
			c++;
		}
	});
	a.innerHTML = m;
	return h == c ? 'add' : 'remove';
}

function tablesFilter(){
	var
	val = qs('#filter-field').value.toLowerCase();

	if (val == FV) { return; }

	FV = val;
	if (val != '') {
		var reg = (val + '').replace(/([\\\.\+\*\?\[\^\]\$\(\)\{\}\=\!\<\>\|\:])/g, '\\$1');
		reg = new RegExp('('+ reg + ')', 'gi');
	}
	if (sessionStorage) { sessionStorage.setItem('adminer_tables_filter',val); }

	var
	i = 0,
	t,	//	li obj describing iterated table
	a,	//	a.structure obj
	n,	//	name of table as string
	tables = qsa('#tables > li');

	for (; i < tables.length; i++) {
		t = tables[i];
		a = null;
		n = t.getAttribute('title');

		if (n == null) {
			a = qsa('a',t)[1];
			n = a.innerHTML.trim();
			a.setAttribute('data-link','main');
		} else {
			a = qs('a[data-link="main"]',t);
		}
		t.setAttribute('title',n);
		a.setAttribute('title',n);
		if (val == '') {
			t.className = '';
			a.innerHTML = n;
		} else {
			t.classList[keywords(a,n,val)]('hidden');
		}
	}
}

function resetFilter(v,s) {
	FV = '-';
	qs('#filter-field').value = s || '';
	tablesFilter();
}

function tablesFilterInput() {
	window.clearTimeout(TO);
	TO = window.setTimeout(tablesFilter, 200);
}

sessionStorage && document.addEventListener('DOMContentLoaded',function(){
	var
	v = sessionStorage.getItem('adminer_tables_filter'),
	d = qs('#dbs > select');
	d = d.options[d.selectedIndex].text;
	if (d == sessionStorage.getItem('adminer_tables_filter_db') && v){
		resetFilter(0,v);
	} else {
		resetFilter();
	}
	sessionStorage.setItem('adminer_tables_filter_db',d);
	qs('#tables > li > .active').parentNode.classList.add('active');
});
</script>
<p class="jsonly">
<input id="filter-field" autocomplete="off" placeholder="filter...">
<input id="filter-reset" type="button" value=" X ">
<?php
		echo script(
			"qs('#filter-field').oninput = tablesFilterInput;"
			."qs('#filter-reset').onclick = resetFilter;"
		);
	}
}
