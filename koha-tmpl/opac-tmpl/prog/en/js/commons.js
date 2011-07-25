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

function getContextBiblioNumbers() {
    return $.session("context_bibnums") || new Array();
}

function setContextBiblioNumbers(bibnums) {
    $.session("context_bibnums", $.unique(bibnums));
}

function getContextPreviousBiblioNumbers() {
    return $.session("context_prevbibnums") || new Array();
}

function setContextPreviousBiblioNumbers(bibnums) {
    $.session("context_prevbibnums", $.unique(bibnums));
}

function getContextAllBiblioNumbers() {
    var all = getContextPreviousBiblioNumbers();
    all.push.apply( all, getContextBiblioNumbers() );
    return all || new Array();
}

function resetSearchContext() {
    $.session("context_bibnums", []);
    $.session("context_prevbibnums", []);
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
});
