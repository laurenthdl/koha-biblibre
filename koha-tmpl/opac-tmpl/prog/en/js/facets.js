function show_more_facets(link_down) {
    var children = $(link_down).parents("ul.facets_list").children("li");
    var num_visible = $(children).find(":visible").length;
    for ( var i = num_visible ; i < num_visible + 10 && i < children.length; i++ ) {
        $(children[i]).show();
    }
    if ( num_visible + 10 >= 100 ) {
        $(link_down).hide();
    } else {
        $(link_down).show();
    }
    $(link_down).siblings().show();
}

function show_less_facets(link_up) {
    var children = $(link_up).parents("ul.facets_list").children("li");
    var num_visible = $(children).find(":visible").length;
    for ( var i = num_visible ; i > num_visible - 10 && i > 10; i-- ) {
        $(children[i - 1]).hide();
    }
    if ( num_visible - 10 <= 10 ) {
        $(link_up).hide();
    } else {
        $(link_up).show();
    }
    $(link_up).siblings().show();
}
