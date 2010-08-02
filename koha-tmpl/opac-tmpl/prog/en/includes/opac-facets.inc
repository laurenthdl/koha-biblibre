<!-- TMPL_IF NAME="opacfacets" -->
<!-- TMPL_IF NAME="facets_loop" -->
<div id="search-facets">
<h4>Refine your search</h4>
<ul>
	<li>Availability<ul><li><!-- TMPL_IF NAME="available" -->Showing only <strong>available</strong> items. <a href="/cgi-bin/koha/opac-search.pl?<!-- TMPL_VAR NAME="query_cgi" --><!-- TMPL_VAR NAME="limit_cgi_not_availablity" --><!-- TMPL_IF NAME="sort_by" -->&amp;sort_by=<!-- TMPL_VAR NAME="sort_by" --><!-- /TMPL_IF -->">Show all items</a><!-- TMPL_ELSE -->Limit to <a href="/cgi-bin/koha/opac-search.pl?<!-- TMPL_VAR NAME="query_cgi" --><!-- TMPL_VAR NAME="limit_cgi" --><!-- TMPL_IF NAME="sort_by" -->&amp;sort_by=<!-- TMPL_VAR NAME="sort_by" --><!-- /TMPL_IF -->&amp;limit=available">currently available items.</a><!-- /TMPL_IF --></li></ul>
	<!-- TMPL_IF NAME="related" --> <li>(related searches: <!-- TMPL_LOOP NAME="related" --><!-- TMPL_VAR NAME="related_search" --><!-- /TMPL_LOOP -->)</li><!-- /TMPL_IF -->
	</li>
	
<!-- TMPL_LOOP NAME="facets_loop" -->
<li>
  <!-- TMPL_VAR NAME="index" -->
  <ul>
    <!-- TMPL_LOOP NAME="values" -->
     <li>
        <a href="/cgi-bin/koha/opac-search.pl?q=<!-- TMPL_VAR NAME="query" --> <!--TMPL_VAR ESCAPE="URL" NAME="index"-->:<!-- TMPL_VAR ESCAPE="URL" NAME="value" -->">
           <!-- TMPL_VAR NAME="value" --></a> (<!-- TMPL_VAR NAME="count" -->)
     </li>
    <!-- /TMPL_LOOP -->
        <li class="showmore"><a href="/cgi-bin/koha/opac-search.pl?<!-- TMPL_VAR NAME="query_cgi" -->&amp;expand=<!-- TMPL_VAR NAME="expand" -->#<!-- TMPL_VAR NAME="type_id" -->">Show More</a></li>
  </ul>
</li>
<!-- /TMPL_LOOP -->
</ul>
</div>
<!-- /TMPL_IF -->
<!-- /TMPL_IF -->
