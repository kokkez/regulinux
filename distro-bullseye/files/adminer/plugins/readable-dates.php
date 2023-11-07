<?php

/** This plugin replaces UNIX timestamps with human-readable dates in your local format.
* Mouse click on the date field reveals timestamp back.
*
* @link https://www.adminer.org/plugins/#use
* @author Anonymous
* @license http://www.apache.org/licenses/LICENSE-2.0 Apache License, Version 2.0
* @license http://www.gnu.org/licenses/gpl-2.0.html GNU General Public License, version 2 (one or other)
*/
class AdminerReadableDates {
	/** @access protected */
	var $prepend;

	function __construct() {
		$this->prepend = <<<EOT

document.addEventListener('DOMContentLoaded',function(){
	var
	i = 0,
	txt = 0,
	dte = new Date(),
	tds = qsa('td[data-text]');		//	querySelectorAll

	for (;i < tds.length; i++)
	{
		txt = tds[i].innerHTML.trim();
		if (txt.match(/^\d{10}$/)) {
			tds[i].orig = txt;
			dte.setTime(1000 * txt);

//			txt = dte.toUTCString().substr(5);	// UTC format
//			txt = dte.toLocaleString();			// Local format
			txt = dte.toLocaleFormat('%F %T');	// Custom format - works in Firefox only

			tds[i].cust = '<div style="color:#f70">'+ txt +'</div>';
			tds[i].innerHTML = tds[i].cust;
			tds[i].isnew = 1;

			tds[i].addEventListener('click',function(event,v,f){
				v = this.orig;
				f = 0;
				if (! event.ctrlKey) {
					v = (this.isnew ? this.orig : this.cust);
					f = !this.isnew;
				}
				this.innerHTML = v;
				this.isnew = f;
			});
		}
	}
});

EOT;
	}

	function head() {
		echo script($this->prepend);
	}
}
