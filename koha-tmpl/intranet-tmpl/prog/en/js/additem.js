function deleteItemBlock(index) {
    var aDiv = document.getElementById(index);
    aDiv.parentNode.removeChild(aDiv);
    var quantity = document.getElementById('quantity');
    quantity.setAttribute('value',parseFloat(quantity.getAttribute('value'))-1);
}

function cloneItemBlock(index) {    
    var original = document.getElementById(index); //original <div>
    var clone = original.cloneNode(true);
    var random = Math.floor(Math.random()*100000); // get a random itemid.
    // set the attribute for the new 'div' subfields
    clone.setAttribute('id',index + random);//set another id.
    var NumTabIndex;
    NumTabIndex = parseInt(original.getAttribute('tabindex'));
    if(isNaN(NumTabIndex)) NumTabIndex = 0;
    clone.setAttribute('tabindex',NumTabIndex+1);

    var CloneButtonPlus;
    var CloneButtonMinus;
    var CloneButtonClear;
    var aTags = clone.getElementsByTagName('a');
    var i = 0;
    while(aTags[i].getAttribute('name') != 'buttonPlus') i++;
    CloneButtonPlus = aTags[i];
    CloneButtonPlus.setAttribute('onclick', "cloneItemBlock('" + index + random + "')");
    CloneButtonMinus = aTags[i+1];
    CloneButtonMinus.setAttribute('onclick', "deleteItemBlock('" + index + random + "')");
    CloneButtonMinus.style.display = 'inline';
    CloneButtonClear = aTags[i+2];
    CloneButtonClear.setAttribute('onclick', "clearItemBlock('" + index + random + "')");

    // change itemids of the clone
    var elems = clone.getElementsByTagName('input');
    for( i = 0 ; elems[i] ; i++ )
    {
        if(elems[i].name.match(/^itemid/)) {
            elems[i].value = random;
        }
    }    
    // insert this line on the page    
    original.parentNode.insertBefore(clone,original.nextSibling);
    var quantity = document.getElementById('quantity');
    quantity.setAttribute('value',parseFloat(quantity.getAttribute('value'))+1);

    // Don't copy value if must be uniq
    // stocknumber copynumber barcode
    var array_fields = ['items.stocknumber', 'items.copynumber', 'items.barcode'];
    for ( field in array_fields ) {
        var input = $(clone).find("[name='kohafield'][value="+array_fields[field]+"]").prevAll("input[name='field_value']")[0];
        $(input).val("");
    }
}

function clearItemBlock(index) {
    var block = $("#"+index);
    console.log("CLEAR FUNCTION");
    console.log($(block));
    $(block).find("input[type='text']").each(function(){
        console.log(this);
        $(this).val("");
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
            console.log(elts[i]);
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

$(document).ready(function(){
	$(".cloneItemBlock").click(function(){
		var clonedRow = $(this).parent().parent().clone(true);
		clonedRow.insertAfter($(this).parent().parent()).find("a.deleteItemBlock").show();
		// find ID of cloned row so we can increment it for the clone
		var count = $("input[id^=volinf]",clonedRow).attr("id");
		var current = Number(count.replace("volinf",""));
		var increment = current + 1;
		// loop over inputs
		var inputs = ["volinf","barcode"];
		jQuery.each(inputs,function() {
			// increment IDs of labels and inputs in the clone
			$("label[for="+this+current+"]",clonedRow).attr("for",this+increment);
			$("input[name="+this+"]",clonedRow).attr("id",this+increment);
		});
		// loop over selects
		var selects = ["homebranch","location","itemtype","ccode"];
		jQuery.each(selects,function() {
			// increment IDs of labels and selects in the clone
			$("label[for="+this+current+"]",clonedRow).attr("for",this+increment);
			$("input[name="+this+"]",clonedRow).attr("id",this+increment);
			$("select[name="+this+"]",clonedRow).attr("id",this+increment);
			// find the selected option and select it in the clone
			var selectedVal = $("select#"+this+current).find("option:selected").attr("value");
			$("select[name="+this+"] option[value="+selectedVal+"]",clonedRow).attr("selected","selected");
		});
		
		var quantityrec = parseFloat($("#quantityrec").attr("value"));
		quantityrec++;
		$("#quantityrec").attr("value",quantityrec);
		return false;
	});
	$(".deleteItemBlock").click(function(){
		$(this).parent().parent().remove();
		var quantityrec = parseFloat($("#quantityrec").attr("value"));
		quantityrec--;
		$("#quantityrec").attr("value",quantityrec);
		return false;
	});
});
