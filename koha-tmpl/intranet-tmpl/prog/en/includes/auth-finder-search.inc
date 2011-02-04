<script type="text/javascript">
//<![CDATA[
YAHOO.util.Event.onContentReady("header_search", function() {
    new function() {
        // Define a custom formatter function
        this.fnCustomFormatter = function(oResultItem, sQuery) {
            var name        = oResultItem[0];
            var aMarkup = [
                "<div class=\"sample-result\">",
                name,
                "<\/div>"];
            return (aMarkup.join(""));
        };

	// marclist
        this.marclistDS = new YAHOO.widget.DS_XHR("/cgi-bin/koha/authorities/ysearch.pl", ["\n", "\t"]);
        this.marclistDS.scriptQueryAppend = "op=do_search&type=intranet&and_or=and&operator=contains&orderby=HeadingAsc&querytype=marclist";
        this.marclistDS.responseType = YAHOO.widget.DS_XHR.TYPE_FLAT;
        this.marclistDS.maxCacheEntries = 60;
        this.marclistDS.queryMatchSubset = false;

        var myInput = document.getElementById('value_any');
        var myContainer = document.getElementById('yvaluecontainermarclist');
        this.oAutoComp = new YAHOO.widget.AutoComplete(myInput,myContainer,this.marclistDS);
        this.oAutoComp.queryDelay = 1;
        this.oAutoComp.formatResult = this.fnCustomFormatter;
        this.oAutoComp.maxResultsDisplayed = 1000;


	// mainentry
	this.mainentryDS = new YAHOO.widget.DS_XHR("/cgi-bin/koha/authorities/ysearch.pl", ["\n", "\t"]);
        this.mainentryDS.scriptQueryAppend = "op=do_search&type=intranet&and_or=and&operator=contains&orderby=HeadingAsc&querytype=mainentry";
        this.mainentryDS.responseType = YAHOO.widget.DS_XHR.TYPE_FLAT;
        this.mainentryDS.maxCacheEntries = 60;
        this.mainentryDS.queryMatchSubset = false;

        var myInput = document.getElementById('value_main');
        var myContainer = document.getElementById('yvaluecontainermainentry');
        this.oAutoComp = new YAHOO.widget.AutoComplete(myInput,myContainer,this.mainentryDS);
        this.oAutoComp.queryDelay = 1;
        this.oAutoComp.formatResult = this.fnCustomFormatter;
        this.oAutoComp.maxResultsDisplayed = 1000;


	// mainmainentry
	this.mainentryDS = new YAHOO.widget.DS_XHR("/cgi-bin/koha/authorities/ysearch.pl", ["\n", "\t"]);
        this.mainentryDS.scriptQueryAppend = "op=do_search&type=intranet&and_or=and&operator=contains&orderby=HeadingAsc&querytype=mainmainentry";
        this.mainentryDS.responseType = YAHOO.widget.DS_XHR.TYPE_FLAT;
        this.mainentryDS.maxCacheEntries = 60;
        this.mainentryDS.queryMatchSubset = false;

        var myInput = document.getElementById('value_mainstr');
        var myContainer = document.getElementById('yvaluecontainermainmainentry');
        this.oAutoComp = new YAHOO.widget.AutoComplete(myInput,myContainer,this.mainentryDS);
        this.oAutoComp.queryDelay = 1;
        this.oAutoComp.formatResult = this.fnCustomFormatter;
        this.oAutoComp.maxResultsDisplayed = 1000;


}
});    
//]]>
</script>


<span id="header_search">
<form name="f" method="get" action="auth_finder.pl">
    <input type="hidden" name="index" value="<!-- TMPL_VAR NAME="index" -->" />
    <input type="hidden" name="op" value="do_search" />
    <fieldset class="rows">
        <ol>
            <li>
                <span class="label">Authority type</span>
                <!-- TMPL_VAR NAME="authtypecode" -->
                <input type="hidden" name="authtypecode" value="<!-- TMPL_VAR NAME="authtypecode" -->" />
            </li>
            <li>
                <label for="mainmainentry">Main entry ($a only): </label>
                <input type="hidden" name="marclist" value="mainmainentry" />
                <input type="text" name="authority_search" value="<!-- TMPL_VAR ESCAPE="HTML" name="authority_search" -->" />

            </li>
            <li>
                <label for="mainentry">Main entry: </label>
                <input type="hidden" name="marclist" value="mainentry" />
                <input type="text" name="main_heading" value="<!-- TMPL_VAR ESCAPE="HTML" name="main_heading" -->" />
            </li>
            <li>
                <label for="marclist">Anywhere: </label>
                <input type="hidden" name="marclist" value="" />
                <input type="text" name="all_headings" value="<!-- TMPL_VAR ESCAPE="HTML" name="value_any" -->" />
            </li>

            <li>
                <label for="orderby">Sort by </label>
                <select name="orderby" id="orderby">
                    <option value="">No order</option>
                    <option value="txt_name asc" selected="selected">Heading Ascendant</option>
                    <option value="txt_name desc">Heading Descendant</option>
                    <option value="int_usedinxbiblios asc">Usage Ascendant</option>
                    <option value="int_usedinxbiblios desc">Usage Descendant</option>
                </select>
            </li>
        </ol>
    </fieldset>
    <fieldset class="action"> <input type="submit" value="Start search" class="submit" /> <a class="cancel close" href="#">Cancel</a></fieldset>
</form>
</span>
