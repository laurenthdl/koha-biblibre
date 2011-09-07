<div id="header-wrapper"><div id="members">
  <!-- TMPL_IF NAME="opacuserlogin" -->
<!-- debut modif brisees -->
<span id="title">Bienvenue sur le catalogue BRISE-ES des bibliothèques d'enseignement supérieur de Saint Etienne</span>
<!-- TMPL_UNLESS NAME="loggedinusername" -->
               <span class="members"><a href="/cgi-bin/koha/opac-user.pl">Log in to Your Account</a></span><!-- /TMPL_UNLESS -->
             <!-- TMPL_IF NAME="loggedinusername" --><span class="members"><a class="logout" id="logout" href="/cgi-bin/koha/opac-main.pl?logout.x=1">Log Out</a></span>
                <span class="members">Welcome, <a href="/cgi-bin/koha/opac-user.pl"><span class="loggedinusername"><!-- TMPL_LOOP NAME="USER_INFO" --><!-- TMPL_VAR NAME="title" --> <!-- TMPL_VAR NAME="firstname" --> <!-- TMPL_VAR NAME="surname" --><!-- /TMPL_LOOP --></span></a></span>

            <!-- /TMPL_IF -->
<!-- debut modif brisees
            <!-- TMPL_IF NAME="ShowOpacRecentSearchLink" -->
                <script type="text/javascript">
                    function ConfirmHistoryDeletion() {
                        return confirm(_('Are you sure you want to delete your search history?'));
                    }
                </script>
                <li><a href="/cgi-bin/koha/opac-search-history.pl" title="View your search history">Search history</a> [<a class="logout" href="/cgi-bin/koha/opac-search-history.pl?action=delete" title="Delete your search history" onclick="return ConfirmHistoryDeletion();">x</a>]</li>
            <!-- /TMPL_IF -->
			<!-- TMPL_IF NAME="loggedinusername" --><span class="members"><a class="logout" id="logout" href="/cgi-bin/koha/opac-main.pl?logout.x=1">Log Out</a></span><!-- /TMPL_IF -->
fin de modif brisees -->
<!-- fin modif brisees -->
  <!-- /TMPL_IF -->
</div>
  <!-- TMPL_IF NAME="opacheader" -->
	<!-- TMPL_VAR NAME="opacheader" -->
  <!-- /TMPL_IF -->
<div id="opac-main-search" class="yui-g">
   <!-- TMPL_IF NAME="opacsmallimage" -->
   <h1 id="libraryname" style="background-image: url('<!-- TMPL_VAR NAME="opacsmallimage" -->');">
   <!-- TMPL_ELSE -->
   <h1 id="libraryname">
   <!-- /TMPL_IF --><a href="/cgi-bin/koha/opac-main.pl"><!-- TMPL_IF NAME="LibraryName" --><!-- TMPL_VAR NAME="LibraryName" --><!-- TMPL_ELSE -->Koha Online Catalog<!-- /TMPL_IF --></a></h1>

<div id="fluid">
<div id="fluid-offset">
<!-- debut ajout brisees -->
<!-- TMPL_IF NAME="advsearch" --><fieldset class="form_rech_adv"> </fieldset><!-- /TMPL_IF -->
<!-- fin ajout brisees -->
<!-- TMPL_UNLESS NAME="advsearch" --><!-- debut modif brisees --><fieldset class="form_rech"><form name="searchform" method="get" action="/cgi-bin/koha/opac-search.pl" id="searchform">
    <label for="masthead_search" class="left"> <!-- Search --><!-- fin modif brisees --> 
	<!-- TMPL_UNLESS NAME="OpacAddMastheadLibraryPulldown" -->
            <!-- TMPL_IF name="mylibraryfirst" --> (in <!-- TMPL_VAR name="mylibraryfirst" --> only)<!-- /TMPL_IF -->
	<!-- /TMPL_UNLESS -->
    </label>
<!-- debut modif brisees -->
        <!-- TMPL_IF NAME="tag" -->
                <input type="text" id = "transl1" name="q" value="" class="form_rech" /><div id="translControl"></div>
        <!-- TMPL_ELSE -->
            <!-- TMPL_IF NAME="query" -->
                    <input type="text" id = "transl1" name="q" size="150" value="<!-- TMPL_VAR ESCAPE="HTML" NAME="query" -->" class="form_rech" /><div id="translControl"></div>
            <!-- TMPL_ELSE -->
                <input type="text" id = "transl1" name="q" size="150" class="form_rech" /><div id="translControl"></div>
            <!-- /TMPL_IF -->
        <!-- /TMPL_IF -->
<br /><br />
<!-- fin modif brisees -->

<!-- debut modif brisees	<select name="idx" id="masthead_search" class="left" style="max-width:10em;width:10em;"> fin modif brisees -->
<!-- debut modif brisees -->
	<select name="idx" id="masthead_search" class="form_rech">
<!-- fin modif brisees -->
	<!-- TMPL_IF NAME="ms_kw" -->
        <option selected="selected" value="">Library Catalog</option>
		<!-- TMPL_ELSE -->
        <option value="">Library Catalog</option>
		<!-- /TMPL_IF -->
		<!-- TMPL_IF NAME="ms_ti" -->
        <option selected="selected" value="title">Title</option>
		<!-- TMPL_ELSE -->
        <option value="title">Title</option>
		<!-- /TMPL_IF -->
		<!-- TMPL_IF NAME="ms_ts-aut" -->
        <option selected="selected" value="ts-aut">Author</option>
		<!-- TMPL_ELSE -->
        <option value="ts-aut">Author</option>
		<!-- /TMPL_IF -->
		<!-- TMPL_IF NAME="ms_su" -->
        <option selected="selected" value="subject">Subject</option>
		<!-- TMPL_ELSE -->
        <option value="subject">Subject</option>
		<!-- /TMPL_IF -->
<!-- 		<!-- TMPL_IF NAME="ms_nb" -->
		<option selected="selected" value="nb">ISBN</option>
		<!-- TMPL_ELSE -->
		<option value="nb">ISBN</option>
		<!-- /TMPL_IF -->  -->
		<!-- TMPL_IF NAME="ms_se" -->
        <option selected="selected" value="title-series">Series</option>
		<!-- TMPL_ELSE -->
        <option value="se">Series</option>
		<!-- /TMPL_IF -->  -->
                <!-- TMPL_IF NAME="ms_isxn" -->
        <option selected="selected" value="isxn">ISBN ISSN ISMN</option>
                <!-- TMPL_ELSE -->
        <option value="isxn">ISBN ISSN ISMN</option>
                <!-- /TMPL_IF -->
		<!-- TMPL_IF NAME="ms_cn" -->
        <option selected="selected" value="cn">Call Number</option>
		<!-- TMPL_ELSE -->
        <option value="cn">Call Number</option>
		<!-- /TMPL_IF --></select>
<!-- debut modif brisees 
        <!-- TMPL_IF NAME="tag" -->
                <input type="text" id = "transl1" name="q" value="" class="left" style="width: 35%; font-size: 111%;"/><div id="translControl"></div>
        <!-- TMPL_ELSE -->
            <!-- TMPL_IF NAME="query" -->
                    <input type="text" id = "transl1" name="q" value="<!-- TMPL_VAR ESCAPE="HTML" NAME="query" -->" class="left" style="width: 35%; font-size: 111%;"/><div id="translControl"></div>
            <!-- TMPL_ELSE -->
                <input type="text" id = "transl1" name="q" class="left" style="width: 35%; font-size: 111%;"/><div id="translControl"></div>
            <!-- /TMPL_IF -->
        <!-- /TMPL_IF -->
fin modif brisees -->
    <!-- TMPL_IF NAME="OpacAddMastheadLibraryPulldown" -->
<!-- debut modif brisees        <select name="filters" id="masthead_branchsearch" class="left" style="max-width:10em;width:10em;"> fin modif brisees -->
<!-- debut modif brisees -->
        <select name="filters" id="masthead_branchsearch" class="form_rech">
<!-- fin modif brisees -->
            <!-- TMPL_IF NAME="branchsearchexistsincookie" -->
              <!-- TMPL_IF EXPR="branchsearch eq ''" -->
                <option value="" selected="selected">All Libraries</option>
              <!-- TMPL_ELSE -->
                <option value="">All Libraries</option>
              <!-- /TMPL_IF -->
            <!-- TMPL_ELSE -->
                <option value="">All Libraries</option>
            <!-- /TMPL_IF -->
            <!-- TMPL_LOOP NAME="BranchesLoop" -->
              <!-- TMPL_IF NAME="branchsearchexistsincookie" -->
                <!-- TMPL_IF EXPR="branchsearch eq value" -->
                  <option selected="selected" value="<!-- TMPL_VAR NAME='holdingbranch_index' -->:<!-- TMPL_VAR NAME='value' -->"><!-- TMPL_VAR NAME='branchname' --></option>
                <!-- TMPL_ELSE -->
                  <option value="<!-- TMPL_VAR NAME='holdingbranch_index' -->:<!-- TMPL_VAR NAME='value' -->"><!-- TMPL_VAR NAME='branchname' --></option>
                <!-- /TMPL_IF -->
              <!-- TMPL_ELSE -->
                <!-- TMPL_IF NAME='mylibraryfirst' -->
                  <!-- TMPL_IF NAME='selected' -->
                    <option selected="selected" value="<!-- TMPL_VAR NAME='holdingbranch_index' -->:<!-- TMPL_VAR NAME='value' -->"><!-- TMPL_VAR NAME='branchname' --></option>
                  <!-- TMPL_ELSE -->
                    <option value="<!-- TMPL_VAR NAME='holdingbranch_index' -->:<!-- TMPL_VAR NAME='value' -->"><!-- TMPL_VAR NAME='branchname' --></option>
                  <!-- /TMPL_IF -->
                <!-- TMPL_ELSE -->
                  <option value="<!-- TMPL_VAR NAME='holdingbranch_index' -->:<!-- TMPL_VAR NAME='value' -->"><!-- TMPL_VAR NAME='branchname' --></option>
                <!-- /TMPL_IF -->
              <!-- /TMPL_IF -->
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

<!-- debut modif brisees
    <input type="submit" value="go" id="searchsubmit" class="left" />
<!-- TMPL_IF NAME="opacbookbag" --><span id="cmspan"></span><!-- /TMPL_IF -->

<!--TMPL_IF NAME="virtualshelves" --><a href="/cgi-bin/koha/opac-shelves.pl" id="listsmenulink" class=""><i></i><span><i></i><span></span>Lists </span></a><!-- /TMPL_IF -->
fin modif brisees -->
    <input type="submit" value="Search" id="searchsubmit" class="right" />
    </form>
    </fieldset>
<!-- TMPL_ELSE -->
<!-- debut modif brisees
<div style="width:80%;*margin-bottom:-30px;">
<!--TMPL_IF NAME="virtualshelves" --><a href="/cgi-bin/koha/opac-shelves.pl" id="listsmenulink" class=""><i></i><span><i></i><span></span>Lists </span></a><!-- /TMPL_IF --><!-- TMPL_IF NAME="opacbookbag" --><span id="cmspan"></span><!-- /TMPL_IF -->
</div>
testes
fin modif brisees -->
<!-- /TMPL_UNLESS -->


<!-- debut modif brisees <div id="moresearches">

<a href="/cgi-bin/koha/opac-search.pl">Advanced Search</a> fin modif brisses -->
<!-- debut modif brisees -->
<div id="moresearches" style="width:570px;" >
<!-- TMPL_IF NAME="advsearch" --><a href="/cgi-bin/koha/opac-main.pl">Simple Search</a>
<!-- TMPL_ELSE --><a href="/cgi-bin/koha/opac-search.pl">Advanced Search</a><!-- /TMPL_IF -->
<!-- fin  modif brisees -->
<!-- debut modif brisees -->
<span class="pipe"> | </span><a href="/cgi-bin/koha/opac-doc-num.pl">Doc Num</a>
<!-- fin  modif brisees -->
<!-- TMPL_IF NAME="OpacBrowser"     --><span class="pipe"> | </span><a href="/cgi-bin/koha/opac-browser.pl">Browse by Hierarchy</a><!-- /TMPL_IF -->
<!-- TMPL_IF NAME="OpacAuthorities" --><span class="pipe"> | </span><a href="/cgi-bin/koha/opac-authorities-home.pl">Browse by author or subject</a><!-- /TMPL_IF -->
<!-- debut modif brisees -->
            <!-- TMPL_IF NAME="ShowOpacRecentSearchLink" -->
                <script type="text/javascript">
                    function ConfirmHistoryDeletion() {
                        return confirm(_('Are you sure you want to delete your search history?'));
                    }
                </script>
                <span class="pipe"> | </span><a href="/cgi-bin/koha/opac-search-history.pl" title="View your search history">Search history</a> [<a class="logout" href="/cgi-bin/koha/opac-search-history.pl?action=delete" title="Delete your search history" onclick="return ConfirmHistoryDeletion();">x</a>]
            <!-- /TMPL_IF -->
<!-- fin modif brisees -->
<!-- debut modif brisees -->
<span style="float:right;">
<!-- TMPL_IF NAME="opacbookbag" --><span id="cmspan"></span><!-- /TMPL_IF -->

<!--TMPL_IF NAME="virtualshelves" --><span class="pipe"> | </span><a href="/cgi-bin/koha/opac-shelves.pl" id="listsmenulink" class=""><i></i><span><i></i><span></span>Lists </span></a><!-- /TMPL_IF -->
</span>
<!-- fin modif brisees -->
<!-- TMPL_IF NAME="TagsEnabled"     --><span class="pipe"> | </span><a href="/cgi-bin/koha/opac-tags.pl">Tag Cloud</a><!-- /TMPL_IF -->
<!-- TMPL_IF NAME="OpacCloud"       --><span class="pipe"> | </span><a href="/cgi-bin/koha/opac-tags_subject.pl">Subject Cloud</a><!-- /TMPL_IF -->
<!-- TMPL_IF NAME="OpacTopissue"    --><span class="pipe"> | </span><a href="/cgi-bin/koha/opac-topissues.pl">Most Popular</a><!-- /TMPL_IF -->
<!-- TMPL_IF NAME="suggestion" -->
  <!-- TMPL_IF NAME="AnonSuggestions" --><span class="pipe"> | </span><a href="/cgi-bin/koha/opac-suggestions.pl">Purchase Suggestions</a>
  <!-- TMPL_ELSIF NAME="OPACViewOthersSuggestions" --><span class="pipe"> | </span><a href="/cgi-bin/koha/opac-suggestions.pl">Purchase Suggestions</a>
  <!-- /TMPL_IF -->
<!-- /TMPL_IF -->
</div>
 </div>
</div>

<!-- TMPL_IF NAME="opacbookbag" --><div id="cartDetails">Your cart is empty.</div><!-- /TMPL_IF -->

<!-- TMPL_IF NAME="virtualshelves" -->
<div id="listsmenu" class="yuimenu" style="display: none">
    <div class="bd">
	<h4>Public Lists</h4>
		<!-- TMPL_IF NAME="pubshelves" -->
			<ul class="first-of-type">
			<!-- TMPL_LOOP NAME="pubshelvesloop" -->
			<li class="yuimenuitem"><a href="/cgi-bin/koha/opac-shelves.pl?viewshelf=<!-- TMPL_VAR NAME="shelfnumber" -->&amp;sortfield=<!-- TMPL_VAR NAME="sortfield" -->"><!-- TMPL_VAR NAME="shelfname"  ESCAPE="html" --></a></li>
			<!-- /TMPL_LOOP -->
			</ul>   
		<!-- TMPL_ELSE -->
			No Public Lists
		<!-- /TMPL_IF -->
		<!-- TMPL_IF NAME="pubtotal" -->
			<ul class="second-of-type">
            <li class="yuimenuitem"><a class="yuimenuitemlabel" href="/cgi-bin/koha/opac-shelves.pl?display=publicshelves">View all <!--TMPL_VAR NAME="pubtotal" --> public lists</a></li>
			</ul>
		<!-- /TMPL_IF -->
  <!-- TMPL_IF NAME="opacuserlogin" -->
    <!-- TMPL_IF NAME="loggedinusername" -->
<h4>Your Lists</h4>
		<!-- TMPL_IF NAME="barshelves" -->
			<ul class="first-of-type">
			<!-- TMPL_LOOP NAME="barshelvesloop" -->
			<li class="yuimenuitem"><a href="/cgi-bin/koha/opac-shelves.pl?viewshelf=<!-- TMPL_VAR NAME="shelfnumber" -->&amp;sortfield=<!-- TMPL_VAR NAME="sortfield" -->"><!-- TMPL_VAR NAME="shelfname"  ESCAPE="html" --></a></li>
			<!-- /TMPL_LOOP -->
			</ul>   
		<!-- TMPL_ELSE -->
			No Private Lists
		<!-- /TMPL_IF -->
		<!-- TMPL_IF NAME="bartotal" -->
			<ul class="second-of-type">
            <li class="yuimenuitem"><a class="yuimenuitemlabel" href="/cgi-bin/koha/opac-shelves.pl?display=privateshelves">View all <!--TMPL_VAR NAME="bartotal" --> of your lists</a></li>
			</ul>
		<!-- /TMPL_IF -->
		<ul class="second-of-type">
        <li class="yuimenuitem"><a class="yuimenuitemlabel" href="/cgi-bin/koha/opac-shelves.pl">Manage Lists</a></li>
        </ul>
    <!-- TMPL_ELSE --><ul class="first-of-type"><li><a href="/cgi-bin/koha/opac-user.pl">Log in to Create Your Own Lists</a></li></ul>
    <!-- /TMPL_IF -->
  <!-- /TMPL_IF -->
	  </div>
</div><!-- /listmenu /virtualshelves -->
<!-- /TMPL_IF -->
<div id="listsDetails"></div>
</div>
</div>
<div id="breadcrumbs" class="yui-g">
<!-- TMPL_IF NAME="searchdesc" --><p><!-- TMPL_IF name="total" --><strong>&ldquo;<!-- TMPL_VAR NAME="query_desc" ESCAPE="HTML"--><!-- TMPL_LOOP NAME="filters" --> <!-- TMPL_VAR NAME="ind" -->:<!-- TMPL_VAR NAME="val" --><!-- /TMPL_LOOP -->&rdquo; </strong>returned <!-- TMPL_VAR NAME="total" ESCAPE="HTML"--> results. <!-- TMPL_IF NAME="related" --> (related searches: <!-- TMPL_LOOP NAME="related" --><!-- TMPL_VAR NAME="related_search" --><!-- /TMPL_LOOP -->). <!-- /TMPL_IF -->
<a href="<!-- TMPL_VAR NAME="OPACBaseURL" -->/cgi-bin/koha/opac-search.pl?<!-- TMPL_VAR name="query_cgi" ESCAPE="HTML" --><!-- TMPL_VAR NAME="limit_cgi"  ESCAPE="HTML" --><!-- TMPL_IF NAME="sort_by" -->&amp;sort_by=<!-- TMPL_VAR NAME="sort_by" ESCAPE="HTML" --><!-- /TMPL_IF -->&amp;format=rss2"><img src="/opac-tmpl/prog/images/feed-icon-16x16.png" alt="Subscribe to this search" title="Subscribe to this search" border="0" /></a>
<!-- TMPL_ELSE -->
<strong>No Result found!</strong>
<p>
    <!-- TMPL_IF NAME="searchdesc" -->
    No results match your search for <span style="font-weight: bold;">&ldquo;<!-- TMPL_VAR NAME="query_desc" ESCAPE="HTML" --> <!-- TMPL_VAR NAME="limit_desc" ESCAPE="HTML"-->&rdquo;</span> in <!-- TMPL_VAR NAME="LibraryName" --> Catalog. <a href="<!-- TMPL_VAR NAME="OPACBaseURL" -->/cgi-bin/koha/opac-search.pl?<!-- TMPL_VAR name="query_cgi" ESCAPE="HTML" --><!-- TMPL_VAR NAME="limit_cgi" ESCAPE="HTML" -->&amp;format=rss2"><img src="/opac-tmpl/prog/images/feed-icon-16x16.png" alt="Subscribe to this search" title="Subscribe to this search" border="0" /></a>
    <!-- TMPL_ELSE -->
    You did not specify any search criteria.
    <!-- /TMPL_IF -->
</p>
</div>
<!-- /TMPL_IF --></p><!-- /TMPL_IF --></div>
