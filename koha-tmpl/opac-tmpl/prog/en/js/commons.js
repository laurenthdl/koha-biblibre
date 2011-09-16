// Extends jQuery API
// http://www.wskidmore.com/downloads/jquery-uniqueArray.min.js
jQuery.extend({uniqueArray:function(e){if($.isArray(e)){var c={};var a,b;for(b=0,a=e.length;b<a;b++){var d=e[b].toString();if(c[d]){e.splice(b,1);a--;b--}else{c[d]=true}}}return(e)}});

function removeByValue(arr, val) {
    for(var i=0; i<arr.length; i++) {
        if(arr[i] == val) {
            arr.splice(i, 1);
            break;
        }
    }
}

function paramOfUrl( url, param ) {
    param = param.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
    var regexS = "[\\?&]"+param+"=([^&#]*)";
    var regex = new RegExp( regexS );
    var results = regex.exec( url );
    if( results == null ) {
        return "";
    } else {
        return results[1];
    }
}

function addBibToContext( bibnum ) {
    var bibnums = getContextBiblioNumbers();
    bibnums.push(bibnum);
    $.session( "context_bibnums", bibnums );
}

function delBibToContext( bibnum ) {
    var bibnums = getContextBiblioNumbers();
    removeByValue( bibnums, bibnum );
    $.session( "context_bibnums", $.uniqueArray( bibnums ) );
}
function getContextBiblioNumbers() {
    return $.session("context_bibnums") || new Array();
}

function resetSearchContext() {
    $.session("context_bibnums", []);
}

$(document).ready(function(){
    // forms with action leading to search
    $("form[action*=opac-search\.pl]").submit(function(){
        resetSearchContext();
    });
    // any link to search but those with class=searchwithcontext
    $("[href*=opac-search\.pl\?]").not(".searchwithcontext").click(function(){
        resetSearchContext();
    });
    // If we are in search.pl, we can't delete session for checkboxes
    var reg = new RegExp("opac-search.pl", "");
    if ( !location.href.match(reg) ) {
        $.session("advsearch_checkboxes", []);
    }
});
