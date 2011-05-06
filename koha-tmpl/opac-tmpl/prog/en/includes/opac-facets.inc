<!-- TMPL_IF NAME="opacfacets" -->
<!-- TMPL_IF NAME="facets_loop" -->
<div id="search-facets">
    <h4>Refine your search</h4>
    <ul>
	    <li>Availability
	        <ul>
	            <li>
	                <!-- TMPL_IF NAME="availability" -->
	                Showing only <strong>available</strong> items.
	                <a href="/cgi-bin/koha/opac-search.pl?q=<!-- TMPL_VAR ESCAPE="URL" NAME="query" --><!-- TMPL_LOOP NAME="filters" --><!-- TMPL_UNLESS EXPR="ind eq 'int_availability'" -->&amp;filters=<!--TMPL_VAR ESCAPE="URL" NAME="ind"-->:&quot;<!--TMPL_VAR ESCAPE="URL" NAME="val"-->&quot;<!-- /TMPL_UNLESS --><!-- /TMPL_LOOP --><!-- TMPL_IF NAME="sort_by" -->&amp;sort_by=<!-- TMPL_VAR ESCAPE="URL" NAME="sort_by" --><!-- /TMPL_IF -->">Show all items</a>
	                <!-- TMPL_ELSE -->
	                Limit to <a href="/cgi-bin/koha/opac-search.pl?q=<!-- TMPL_VAR ESCAPE="URL" NAME="query" --><!-- TMPL_LOOP NAME="filters" --><!-- TMPL_UNLESS EXPR="ind eq index" -->&amp;filters=<!--TMPL_VAR ESCAPE="URL" NAME="ind"-->:&quot;<!--TMPL_VAR ESCAPE="URL" NAME="val"-->&quot;<!-- /TMPL_UNLESS --><!-- /TMPL_LOOP -->&amp;filters=int_availability:&quot;1&quot;<!-- TMPL_IF NAME="sort_by" -->&amp;sort_by=<!-- TMPL_VAR ESCAPE="URL" NAME="sort_by" --><!-- /TMPL_IF -->">currently available items.</a>
	                <!-- /TMPL_IF -->
	            </li>
	        </ul>
	        <!-- TMPL_IF NAME="related" -->
	        <li>(related searches: <!-- TMPL_LOOP NAME="related" --><!-- TMPL_VAR NAME="related_search" --><!-- /TMPL_LOOP -->)</li>
	        <!-- /TMPL_IF -->
	    </li>
        <li><a href="#" id="expand_sign">[+]</a> <!-- TMPL_VAR NAME="itemtypelib" -->
            <div id="itypes_form" style="display:none;">
                <form action="opac-search.pl" method="get">
                    <!-- TMPL_LOOP NAME="follower_params" -->
                        <input type="hidden" name="<!-- TMPL_VAR ESCAPE="HTML" NAME="ind" -->" value="<!-- TMPL_VAR ESCAPE="HTML" NAME="val" -->" />
                    <!-- /TMPL_LOOP -->
                    <ul>
                        <!--TMPL_LOOP Name="itemtypeloop"-->
                            <li>
                                <input type="checkbox" name="itypes" value="<!-- TMPL_VAR NAME="code" -->" <!-- TMPL_IF EXPR="selected eq '1'" --> checked="checked" <!-- /TMPL_IF -->/>
                                <!-- TMPL_VAR NAME="description" -->
                            </li>
                        <!--/TMPL_LOOP-->
                    </ul>
                    <input class="submit" type="submit" value="Filter !" />
                </form>
            </div>
        </li>
        <!-- TMPL_LOOP NAME="facets_loop" -->
        <li>
            <!-- TMPL_VAR NAME="label" -->
            <ul>
                <!-- TMPL_LOOP NAME="values" -->
                <li>
                    <!-- TMPL_IF NAME="active" -->
                        <!-- TMPL_VAR NAME="lib" -->
                        (<!-- TMPL_VAR NAME="count" -->)
                        [<a href="/cgi-bin/koha/opac-search.pl?<!-- TMPL_LOOP NAME="follower_params" --><!--TMPL_IF EXPR="ind ne 'filters'"--><!-- TMPL_VAR ESCAPE="URL" NAME="ind" -->=<!-- TMPL_VAR ESCAPE="URL" NAME="val" -->&amp;<!-- /TMPL_IF --><!-- /TMPL_LOOP --><!-- TMPL_LOOP NAME="filters" --><!-- TMPL_UNLESS EXPR="ind eq index && val eq value" -->filters=<!--TMPL_VAR ESCAPE="URL" NAME="ind"-->:&quot;<!--TMPL_VAR ESCAPE="URL" NAME="val"-->&quot;&amp;<!-- /TMPL_UNLESS --><!-- /TMPL_LOOP -->">x</a>]
                    <!-- TMPL_ELSE -->
                        <a href="/cgi-bin/koha/opac-search.pl?<!-- TMPL_LOOP NAME="follower_params" --><!--TMPL_IF EXPR="ind ne 'filters'"--><!-- TMPL_VAR ESCAPE="URL" NAME="ind" -->=<!-- TMPL_VAR ESCAPE="URL" NAME="val" -->&amp;<!-- /TMPL_IF --><!-- /TMPL_LOOP --><!-- TMPL_LOOP NAME="filters" --><!-- TMPL_UNLESS EXPR="ind eq index" -->&amp;filters=<!--TMPL_VAR ESCAPE="URL" NAME="ind"-->:&quot;<!--TMPL_VAR ESCAPE="URL" NAME="val"-->&quot;<!-- /TMPL_UNLESS --><!-- /TMPL_LOOP -->&amp;filters=<!--TMPL_VAR ESCAPE="URL" NAME="index"-->:&quot;<!-- TMPL_VAR ESCAPE="URL" NAME="value" -->&quot;">
                            <!-- TMPL_VAR NAME="lib" -->
                        </a>
                        (<!-- TMPL_VAR NAME="count" -->)
                    <!-- /TMPL_IF -->
                </li>
                <!-- /TMPL_LOOP -->
            </ul>
        </li>
        <!-- /TMPL_LOOP -->
    </ul>
</div>
<!-- /TMPL_IF -->
<!-- /TMPL_IF -->
