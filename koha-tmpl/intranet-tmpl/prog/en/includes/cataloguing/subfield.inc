      <div class="subfield_line" style="<!-- TMPL_VAR NAME='visibility' -->; float: left; clear: left; width: 100%;" id="subfield<!-- TMPL_VAR NAME='tag' --><!-- TMPL_VAR NAME='subfield' --><!-- TMPL_VAR name="random" -->">
            
                <!--TMPL_UNLESS NAME="advancedMARCEditor" -->
                    <label for="tag_<!-- TMPL_VAR NAME='tag'-->_subfield_<!--  TMPL_VAR NAME='subfield'-->_<!-- TMPL_VAR NAME='index'-->_<!-- TMPL_VAR NAME='index_subfield'-->" <!-- TMPL_IF NAME="fixedfield" --> style="display:none;" <!-- /TMPL_IF --> class="labelsubfield">
                <!-- /TMPL_UNLESS --> 
                
                <!-- TMPL_UNLESS name="hide_marc" -->
                <span class="subfieldcode"><!-- TMPL_IF NAME="fixedfield" --> 
                        <img class="buttonUp" style="display:none;" src="<!-- TMPL_VAR NAME="themelang" -->/../img/up.png" onclick="upSubfield('subfield<!-- TMPL_VAR NAME='tag' --><!-- TMPL_VAR NAME='subfield' --><!-- TMPL_VAR name="random" -->')" alt="Move Up" title="Move Up" />
                    <!-- TMPL_ELSE -->
                        <img class="buttonUp" src="<!-- TMPL_VAR NAME="themelang" -->/../img/up.png" onclick="upSubfield('subfield<!-- TMPL_VAR NAME='tag' --><!-- TMPL_VAR NAME='subfield' --><!-- TMPL_VAR name="random" -->')" alt="Move Up" title="Move Up" />
                    <!-- /TMPL_IF -->
                        <input title="<!-- TMPL_VAR NAME='marc_lib_plain' -->" style=" <!-- TMPL_IF NAME="fixedfield" -->display:none; <!-- /TMPL_IF -->border:0;" type="text" tabindex="0" name="tag_<!-- TMPL_VAR NAME='tag'-->_code_<!--  TMPL_VAR NAME='subfield'-->_<!-- TMPL_VAR NAME='index'-->_<!-- TMPL_VAR NAME='index_subfield'-->" value="<!-- TMPL_VAR NAME="subfield" -->" size="1" maxlength="1" class="flat" />
 </span>
                <!-- TMPL_ELSE -->
                    <input type="hidden" name="tag_<!-- TMPL_VAR NAME='tag'-->_code_<!--  TMPL_VAR NAME='subfield'-->_<!-- TMPL_VAR NAME='index'-->_<!-- TMPL_VAR NAME='index_subfield'-->" value="<!-- TMPL_VAR NAME="subfield" -->" />
 </span>
                <!-- /TMPL_UNLESS -->
            
                <!-- TMPL_UNLESS NAME="advancedMARCEditor" -->
                    <!-- TMPL_IF name="mandatory" --><span class="subfield subfield_mandatory"><!-- TMPL_ELSE --><span class="subfield"><!-- /TMPL_IF -->
                        <!-- TMPL_VAR NAME="marc_lib_plain" -->
                        <!-- TMPL_IF NAME="mandatory" --><span class="mandatory_marker" title="This field is mandatory">*</span><!-- /TMPL_IF -->
                    </span>
                    </label>
                <!-- /TMPL_UNLESS -->
                
                <!-- TMPL_VAR NAME="marc_value" -->
                
                <!-- TMPL_IF NAME="repeatable" -->
                    <span class="buttonPlus" onclick="CloneSubfield('subfield<!-- TMPL_VAR NAME='tag' --><!-- TMPL_VAR NAME='subfield' --><!-- TMPL_VAR name="random" -->')">+</span>
                <!-- /TMPL_IF -->
                <!-- TMPL_UNLESS NAME="mandatory" -->
                    <span class="buttonMinus" onclick="UnCloneField('subfield<!-- TMPL_VAR NAME='tag' --><!-- TMPL_VAR NAME='subfield' --><!-- TMPL_VAR name="random" -->')">&#8722;</span>
                <!-- /TMPL_UNLESS -->
                
            </div>
            <!-- End of the line -->
 

