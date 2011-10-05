<!-- TMPL_IF NAME="facets" -->
<!-- TMPL_IF NAME="facets_loop" -->
<div id="search-facets">
    <h4>Refine your search</h4>
    <ul>
        <li>Availability
            <ul>
                <li>
                    <!-- TMPL_IF NAME="availability" -->
                    Showing only <strong>available</strong> items.
                    <a href="/cgi-bin/koha/catalogue/search.pl?q=<!-- TMPL_VAR ESCAPE="URL" NAME="query" --><!-- TMPL_LOOP NAME="filters" --><!-- TMPL_UNLESS EXPR="ind eq availability_indexname" -->&amp;filters=<!--TMPL_VAR ESCAPE="URL" NAME="ind"-->:&quot;<!--TMPL_VAR ESCAPE="URL" NAME="val"-->&quot;<!-- /TMPL_UNLESS --><!-- /TMPL_LOOP --><!-- TMPL_IF NAME="sort_by" -->&amp;sort_by=<!-- TMPL_VAR ESCAPE="URL" NAME="sort_by" --><!-- /TMPL_IF -->">Show all items</a>
                    <!-- TMPL_ELSE -->
                    Limit to <a href="/cgi-bin/koha/catalogue/search.pl?q=<!-- TMPL_VAR ESCAPE="URL" NAME="query" --><!-- TMPL_LOOP NAME="filters" --><!-- TMPL_UNLESS EXPR="ind eq indexname" -->&amp;filters=<!--TMPL_VAR ESCAPE="URL" NAME="ind"-->:&quot;<!--TMPL_VAR ESCAPE="URL" NAME="val"-->&quot;<!-- /TMPL_UNLESS --><!-- /TMPL_LOOP -->&amp;filters=<!-- TMPL_VAR NAME="availability_indexname" -->:&quot;1&quot;<!-- TMPL_IF NAME="sort_by" -->&amp;sort_by=<!-- TMPL_VAR ESCAPE="URL" NAME="sort_by" --><!-- /TMPL_IF -->">currently available items.</a>
                    <!-- /TMPL_IF -->
                </li>
            </ul>
            <!-- TMPL_IF NAME="related" -->
            <li>(related searches: <!-- TMPL_LOOP NAME="related" --><!-- TMPL_VAR NAME="related_search" --><!-- /TMPL_LOOP -->)</li>
            <!-- /TMPL_IF -->
        </li>

        <!-- TMPL_LOOP NAME="facets_loop" -->
        <li>
            <!-- TMPL_VAR NAME="label" -->
            <ul class="facets_list">
                <!-- TMPL_LOOP NAME="values" -->
                    <!-- TMPL_IF EXPR="__counter__ <= 10" -->
                        <li>
                    <!-- TMPL_ELSE -->
                        <li style="display:none;">
                    <!-- /TMPL_IF -->
                    <!-- TMPL_IF NAME="active" -->
                        <!-- TMPL_VAR NAME="lib" -->
                        (<!-- TMPL_VAR NAME="count" -->)
                        [<a href="/cgi-bin/koha/catalogue/search.pl?<!-- TMPL_LOOP NAME="follower_params" --><!--TMPL_IF EXPR="ind ne 'filters'"--><!-- TMPL_VAR ESCAPE="URL" NAME="ind" -->=<!-- TMPL_VAR ESCAPE="URL" NAME="val" -->&amp;<!-- /TMPL_IF --><!-- /TMPL_LOOP --><!-- TMPL_LOOP NAME="filters" --><!-- TMPL_UNLESS EXPR="ind eq indexname && val eq value" -->filters=<!--TMPL_VAR ESCAPE="URL" NAME="ind"-->:&quot;<!--TMPL_VAR ESCAPE="URL" NAME="val"-->&quot;&amp;<!-- /TMPL_UNLESS --><!-- /TMPL_LOOP -->">x</a>]
                    <!-- TMPL_ELSE -->
                        <a href="/cgi-bin/koha/catalogue/search.pl?<!-- TMPL_LOOP NAME="follower_params" --><!--TMPL_IF EXPR="ind ne 'filters'"--><!-- TMPL_VAR ESCAPE="URL" NAME="ind" -->=<!-- TMPL_VAR ESCAPE="URL" NAME="val" -->&amp;<!-- /TMPL_IF --><!-- /TMPL_LOOP --><!-- TMPL_LOOP NAME="filters" -->&amp;filters=<!--TMPL_VAR ESCAPE="URL" NAME="ind"-->:&quot;<!--TMPL_VAR ESCAPE="URL" NAME="val"-->&quot;<!-- /TMPL_LOOP -->&amp;filters=<!--TMPL_VAR ESCAPE="URL" NAME="indexname"-->:&quot;<!-- TMPL_VAR ESCAPE="URL" NAME="value" -->&quot;">
                            <!-- TMPL_VAR NAME="lib" -->
                        </a>
                        (<!-- TMPL_VAR NAME="count" -->)
                    <!-- /TMPL_IF -->
                </li>
                <!-- /TMPL_LOOP -->
                <div class="facets_arrows">
                    <a href="#" alt="show less facets" onclick="show_less_facets(this); return false;" style="display:none;">
                        <img src="<!-- TMPL_VAR NAME="themelang" -->/../img/more-up-arrow.gif" alt="show less facets" />
                    </a>
                    <!-- TMPL_IF EXPR="size <= 10" -->
                        <a href="#" alt="show more facets" onclick="show_more_facets(this); return false;" style="display:none;" data-size="<!-- TMPL_VAR NAME="size"-->" >
                    <!-- TMPL_ELSE -->
                        <a href="#" alt="show more facets" onclick="show_more_facets(this); return false;" data-size="<!-- TMPL_VAR NAME="size"-->" >
                    <!-- /TMPL_IF -->
                        <img src="<!-- TMPL_VAR NAME="themelang" -->/../img/more-arrow.gif" alt="show more facets" />
                    </a>
                </div>
            </ul>
        </li>
        <!-- /TMPL_LOOP -->
    </ul>
</div>
<!-- /TMPL_IF -->
<!-- /TMPL_IF -->
