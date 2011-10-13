<!-- TMPL_IF NAME="opacheader" -->
    <!-- TMPL_VAR NAME="opacheader" -->
<!-- /TMPL_IF -->
<div id="opac-banner">
    <!-- TMPL_IF NAME="opacsmallimage" -->
        <h1 id="libraryname" style="background-image: url('<!-- TMPL_VAR NAME="opacsmallimage" -->');">
    <!-- TMPL_ELSE -->
        <h1 id="libraryname">
    <!-- /TMPL_IF -->
    <a href="/cgi-bin/koha/opac-main.pl"><!-- TMPL_IF NAME="LibraryName" --><!-- TMPL_VAR NAME="LibraryName" --><!-- TMPL_ELSE -->Koha Online Catalog<!-- /TMPL_IF --></a>
    </h1>
</div>

<div id="header-wrapper">
    <div id="members">
    <!-- TMPL_IF NAME="opacuserlogin" -->
        <ul>
        <!-- TMPL_IF NAME="loggedinusername" -->
            <li>
                <span class="members">Welcome, <a href="/cgi-bin/koha/opac-user.pl"><span class="loggedinusername">
                <!-- TMPL_LOOP NAME="USER_INFO" -->
                    <!-- TMPL_VAR NAME="title" --> <!-- TMPL_VAR NAME="firstname" --> <!-- TMPL_VAR NAME="surname" -->
                <!-- /TMPL_LOOP -->
                </span></a></span>
            </li>
            <li>(<a class="logout" id="logout" href="/cgi-bin/koha/opac-main.pl?logout.x=1">Log Out</a>)</li>
            <li><a href="/cgi-bin/koha/opac-shelves.pl?display=privateshelves">My lists</a></li>
            <!-- TMPL_IF NAME="opacbookbag" --><li><span id="cmspan"></span></li><!-- /TMPL_IF -->
        <!-- TMPL_ELSE -->
            <li><a href="/cgi-bin/koha/opac-user.pl">Log in to Your Account</a></li>
        <!-- /TMPL_IF -->
    <!-- /TMPL_IF -->
    </div>
</div>

<div id="opac-main-search">
<div id="fluid">
<div id="fluid-offset">
<!-- TMPL_UNLESS NAME="advsearch" -->
    <div id="global_search">
        <fieldset>
        <legend>Search</legend>
        <form name="searchform" method="get" action="/cgi-bin/koha/opac-search.pl" id="searchform">
        <label for="masthead_search">
            <!-- TMPL_UNLESS NAME="OpacAddMastheadLibraryPulldown" -->
                <!-- TMPL_IF name="mylibraryfirst" --> (in <!-- TMPL_VAR name="mylibraryfirst" --> only)<!-- /TMPL_IF -->
            <!-- /TMPL_UNLESS -->
        </label>
        <input type="text" id = "transl1" name="q"/><div id="translControl"></div>
        <input type="submit" value="Go" id="searchsubmit" />
        <!-- TMPL_IF NAME="OpacAddMastheadLibraryPulldown" -->
            <select name="filters" id="masthead_search">
                <option value="">All Libraries</option>
                <!-- TMPL_LOOP NAME="BranchesLoop" -->
                    <option <!-- TMPL_IF name="mylibraryfirst" --><!-- TMPL_IF NAME="selected" -->selected="selected"<!-- /TMPL_IF --><!-- /TMPL_IF --> value="<!-- TMPL_VAR NAME='holdingbranch_index' -->:<!-- TMPL_VAR NAME='value' -->"><!-- TMPL_VAR NAME='branchname' --></option>
                <!-- /TMPL_LOOP -->
            </select>
        <!-- TMPL_ELSE -->
            <!-- TMPL_UNLESS NAME="opac_limit_override" -->
                <!-- TMPL_IF name="mylibraryfirst" --> 
                    <input name="filters" value="<!-- TMPL_VAR NAME='holdingbranch_index' -->:<!-- TMPL_VAR name='mylibraryfirst' -->" type="hidden" />
                <!-- /TMPL_IF -->
            <!-- /TMPL_UNLESS -->
        <!-- /TMPL_IF -->
        <!-- TMPL_IF NAME="opac_search_limit" -->
            <input name="limit" value="<!-- TMPL_VAR name="opac_search_limit" -->" type="hidden" />
        <!-- /TMPL_IF -->
        </form>
        </fieldset>
    </div>
</div>
</div>
</div>
