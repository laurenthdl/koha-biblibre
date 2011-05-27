function addItem( node ) {
    var index = $(node).parent().attr('id');
    var current_qty = parseInt($("#quantity").val());
    var max_qty = parseInt($("#quantity_to_receive").val());
    if ( $("#items_list table").find('tr[idblock="' + index + '"]').length == 0 ) {
        if ( current_qty < max_qty ) {
            if ( current_qty < max_qty - 1 )
                cloneItemBlock(index);
            addItemInList(index);
            $("#quantity").val(current_qty + 1);
        } else if ( current_qty >= max_qty ) {
            alert(_("You can't receive any more items."));
        }
    } else {
        if ( current_qty < max_qty )
            cloneItemBlock(index);
        var tr = constructTrNode(index);
        $("#items_list table").find('tr[idblock="' + index + '"]:first').replaceWith(tr);
    }
    $("#" + index).hide();
}

function showItem(index) {
    $("#outeritemblock").children("div").each(function(){
        if ( $(this).attr('id') == index ) {
            $(this).show();
        } else {
            if ( $("#items_list table").find('tr[idblock="' + $(this).attr('id') + '"]').length == 0 ) {
                $(this).remove();
            } else {
                $(this).hide();
            }
        }
    });
}

function constructTrNode(index) {
    var homebranch = $("#" + index).find("[name='kohafield'][value='items.homebranch']").prevAll("[name='field_value']")[0];
    homebranch = $(homebranch).val();
    var loc = $("#" + index).find("[name='kohafield'][value='items.location']").prevAll("[name='field_value']")[0];
    loc = $(loc).val();
    var callnumber = $("#" + index).find("[name='kohafield'][value='items.itemcallnumber']").prevAll("[name='field_value']")[0];
    callnumber = $(callnumber).val();
    var notforloan = $("#" + index).find("[name='kohafield'][value='items.notforloan']").prevAll("[name='field_value']")[0];
    notforloan = $(notforloan).val();
    var barcode = $('#' + index).find("[name='kohafield'][value='items.barcode']").prevAll("[name='field_value']")[0];
    barcode = $(barcode).val();
    var show_link = "<a href='#items' onclick='showItem(\"" + index + "\");'>Show</a>";
    var del_link = "<a href='#' onclick='deleteItemBlock(this, \"" + index + "\");'>Delete</a>";
    var result = "<tr idblock='" + index + "'>";
    result += "<td>" + homebranch + "</td>";
    result += "<td>" + loc + "</td>";
    result += "<td>" + callnumber + "</td>";
    result += "<td>" + notforloan + "</td>";
    result += "<td>" + barcode + "</td>";
    result += "<td>" + show_link + "</td>";
    result += "<td>" + del_link + "</td>";
    result += "</tr>";

    return result;
}

function addItemInList(index) {
    $("#items_list").show();
    var tr = constructTrNode(index);
    $("#items_list table tbody").append(tr);
}

function deleteItemBlock(node_a, index) {
    $("#" + index).remove();
    var current_qty = parseInt($("#quantity").val());
    var max_qty = parseInt($("#quantity_to_receive").val());
    $("#quantity").val(current_qty - 1);
    $(node_a).parents('tr').remove();
    if(current_qty - 1 == 0)
        $("#items_list").hide();

    if ( $("#quantity").val() <= max_qty - 1) {
        if ( $("#outeritemblock").children("div :visible").length == 0 ) {
            $("#outeritemblock").children("div:last").show();
        }
    }
    if ( $("#quantity").val() == 0 && $("#outeritemblock > div").length == 0) {
        var new_form = $("#to_cloned").children('div').clone();
        $(new_form).attr('id', 'itemblock');
        $("#outeritemblock").append(new_form);
    }
}

function cloneItemBlock(index) {
    var original = $("#" + index); //original <div>

    var clone = $(original).clone(true);
    var random = Math.floor(Math.random()*100000); // get a random itemid.
    // set the attribute for the new 'div' subfields
    $(clone).attr('id', index + random);//set another id.

    // change itemids of the clone
    var elems = $(clone).find('input');
    for( i = 0 ; elems[i] ; i++ ) {
        if(elems[i].name.match(/^itemid/)) {
            elems[i].value = random;
        }
    }

    // Insert block in items block
    $("#outeritemblock").append($(clone));

    // Don't copy value if must be uniq
    // stocknumber copynumber barcode
    var array_fields = ['items.stocknumber', 'items.copynumber', 'items.barcode'];
    for ( field in array_fields ) {
        var input = $(clone).find("[name='kohafield'][value="+array_fields[field]+"]").prevAll("input[name='field_value']")[0];
        $(input).val("");
    }

    // Set select value from original node
    $(original).find("select").each(function(){
        var parent_id = $(this).parent('div').attr('id');
        var select_cloned = $(clone).find('div[id='+parent_id+']').find('select[name=field_value]');
        var select_original = $(original).find('div[id='+parent_id+']').find('select[name=field_value]');
        var option_value = $(select_original).find('option[selected=true]').val();
        select_cloned.find('option[value='+option_value+']').attr('selected', true);
    });

}

function clearItemBlock(node) {
    var index = $(node).parent().attr('id');
    var block = $("#"+index);
    $(block).find("input[type='text']").each(function(){
        $(this).val("");
    });
    $(block).find("select").each(function(){
        $(this).find("option:first").attr("selected", true);
    });
}

function check_additem() {
	var success = true;
    var array_fields = ['items.stocknumber', 'items.copynumber', 'items.barcode'];
    var url = '../acqui/check_unicity.pl?'; // Url for ajax call
    $(".error").empty(); // Clear error div

    // Check if a value is duplicated in form
    for ( field in array_fields ) {
        var fieldname = array_fields[field].split('.')[1];
        var values = new Array();
        $("[name='kohafield'][value="+array_fields[field]+"]").each(function(){
            var input = $(this).prevAll("input[name='field_value']")[0];
            values.push($(input).val());
            url += "field=" + fieldname + "&value=" + $(input).val() + "&"; // construct url
        });

        var sorted_arr = values.sort();
        for (var i = 0; i < sorted_arr.length - 1; i += 1) {
            if (sorted_arr[i + 1] == sorted_arr[i]) {
                $(".error").append( fieldname + " " + sorted_arr[i] + " is duplicated<br/>");
                success = false;
            }
        }
    }

    // If there is a duplication, we raise an error
    if ( success == false ) {
        $(".error").show();
        return false;
    }

    // Else, we check in DB
    var xmlhttp = null;
    xmlhttp = new XMLHttpRequest();
    if ( typeof xmlhttp.overrideMimeType != 'undefined') {
        xmlhttp.overrideMimeType('text/xml');
    }

    xmlhttp.open('GET', url, false);
    xmlhttp.send(null);

    xmlhttp.onreadystatechange = function() {
        if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {} else {}
    };
    var response  =  xmlhttp.responseText;
    var elts = response.split(';');
    if ( response.length > 0 && elts.length > 0 ) {
        for ( var i = 0 ; i < elts.length - 1 ; i += 1 ) {
            var fieldname = elts[i].split(':')[0];
            var value = elts[i].split(':')[1];
            $(".error").append( fieldname + " " + value + " already exist in database<br/>");
        }
        success = false;
    }

    if ( success == false ) {
        $(".error").show();
    }
    return success;
}

