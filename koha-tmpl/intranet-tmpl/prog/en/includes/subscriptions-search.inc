<div id="advsearch">
    <form action="" method="get">
        <fieldset class="brief">
            <a id="unfold_advsearch" style="cursor:pointer" onclick="$('#advsearch_form').slideToggle(400);">Advanced search</a>
            <div id="advsearch_form" style="display:none">
            <ol>
              <li>
                <label for="issn">ISSN:</label>
                <input type="text" id="issn" name="ISSN_filter" value="<!-- TMPL_VAR NAME='ISSN_filter' -->" />
              </li>
              <li>
                <label for="title">Title:</label>
                <input type="text" id="title" name="title_filter" value="<!-- TMPL_VAR NAME='title_filter' -->" />
              </li>
              <li>
                <label for="ean">EAN:</label>
                <input type="text" id="ean" name="EAN_filter" value="<!-- TMPL_VAR NAME='EAN_filter' -->" />
              </li>
              <li>
                <label for="publisher">Publisher:</label>
                <input type="text" id="publisher" name="publisher_filter" value="<!-- TMPL_VAR NAME='publisher_filter' -->" />
              </li>
              <li>
                <label for="supplier">Supplier:</label>
                <input type="text" id="supplier" name="supplier_filter" value="<!-- TMPL_VAR NAME='supplier_filter' -->" />
              </li>
              <li>
                <label for="branch">Branch:</label>
                <select id="branch" name="branch_filter">
                  <option value="">All</option>
                  <!-- TMPL_LOOP NAME="branches_loop" -->
                    <!-- TMPL_IF NAME="selected" -->
                      <option selected="selected" value="<!-- TMPL_VAR NAME='branchcode' -->"><!-- TMPL_VAR NAME="branchname" --></option>
                    <!-- TMPL_ELSE -->
                      <option value="<!-- TMPL_VAR NAME='branchcode' -->"><!-- TMPL_VAR NAME="branchname" --></option>
                    <!-- /TMPL_IF -->
                  <!-- /TMPL_LOOP -->
                </select>
              </li>
            </ol>
            <input type="hidden" name="searched" value="1" />
            <!-- TMPL_IF NAME="booksellerid" -->
                <input type="hidden" name="booksellerid" value="<!-- TMPL_VAR NAME="booksellerid" -->" />
            <!-- /TMPL_IF -->
            <!-- TMPL_IF NAME="basketno" -->
                <input type="hidden" name="basketno" value="<!-- TMPL_VAR NAME="basketno" -->" />
            <!-- /TMPL_IF -->
            <fieldset class="action">
              <input type="submit" value="Search" />
            </fieldset>
            </div>
        </fieldset>
    </form>
</div>

