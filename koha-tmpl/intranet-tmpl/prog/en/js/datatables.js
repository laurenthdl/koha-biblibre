$.fn.dataTableExt.oApi.fnGetColumnData = function ( oSettings, iColumn, bUnique, bFiltered, bIgnoreEmpty ) {
    // check that we have a column id
    if ( typeof iColumn == "undefined" ) return new Array();
    // by default we only wany unique data
    if ( typeof bUnique == "undefined" ) bUnique = true;
    // by default we do want to only look at filtered data
    if ( typeof bFiltered == "undefined" ) bFiltered = true;
    // by default we do not wany to include empty values
    if ( typeof bIgnoreEmpty == "undefined" ) bIgnoreEmpty = true;
    // list of rows which we're going to loop through
    var aiRows;
    // use only filtered rows
    if (bFiltered == true) aiRows = oSettings.aiDisplay; 
    // use all rows
    else aiRows = oSettings.aiDisplayMaster; // all row numbers

    // set up data array    
    var asResultData = new Array();
    for (var i=0,c=aiRows.length; i<c; i++) {
        iRow = aiRows[i];
        var aData = this.fnGetData(iRow);
        var sValue = aData[iColumn];
        // ignore empty values?
        if (bIgnoreEmpty == true && sValue.length == 0) continue;
        // ignore unique values?
        else if (bUnique == true && jQuery.inArray(sValue, asResultData) > -1) continue;
        // else push the value onto the result data array
        else asResultData.push(sValue);
    }
    return asResultData;
}

jQuery.fn.dataTableExt.oApi.fnSetFilteringDelay = function ( oSettings, iDelay ) {
    /*
     * Inputs:      object:oSettings - dataTables settings object - automatically given
     *              integer:iDelay - delay in milliseconds
     * Usage:       $('#example').dataTable().fnSetFilteringDelay(250);
     * Author:      Zygimantas Berziunas (www.zygimantas.com) and Allan Jardine
     * License:     GPL v2 or BSD 3 point style
     * Contact:     zygimantas.berziunas /AT\ hotmail.com
     */
    var
        _that = this,
        iDelay = (typeof iDelay == 'undefined') ? 250 : iDelay;

    this.each( function ( i ) {
        $.fn.dataTableExt.iApiIndex = i;
        var
            $this = this,
            oTimerId = null,
            sPreviousSearch = null,
            anControl = $( 'input', _that.fnSettings().aanFeatures.f );

        anControl.unbind( 'keyup.DT' ).bind( 'keyup.DT', function() {
            var $$this = $this;

            if (sPreviousSearch === null || sPreviousSearch != anControl.val()) {
                window.clearTimeout(oTimerId);
                sPreviousSearch = anControl.val();
                oTimerId = window.setTimeout(function() {
                    $.fn.dataTableExt.iApiIndex = i;
                    _that.fnFilter( anControl.val() );
                }, 5000);
            }
        });

        return this;
    } );
    return this;
}

function dt_add_rangedate_filter(begindate_id, enddate_id, dateCol) {
    $.fn.dataTableExt.afnFiltering.push(
        function( oSettings, aData, iDataIndex ) {

            var beginDate = Date_from_syspref($("#"+begindate_id).val()).getTime();
            var endDate   = Date_from_syspref($("#"+enddate_id).val()).getTime();

            var data = Date_from_syspref(aData[dateCol]).getTime();

            if ( !parseInt(beginDate) && ! parseInt(endDate) ) {
                return true;
            }
            else if ( beginDate <= data && !parseInt(endDate) ) {
                return true;
            }
            else if ( data <= endDate && !parseInt(beginDate) ) {
                return true;
            }
            else if ( beginDate <= data && data <= endDate) {
                return true;
            }
            return false;
        }
    );
}

function dt_add_type_uk_date() {
  jQuery.fn.dataTableExt.aTypes.unshift(
    function ( sData )
    {
      if (sData.match(/(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[012])\/(19|20|21)\d\d/))
      {
        return 'uk_date';
      }
      return null;
    }
  );

  jQuery.fn.dataTableExt.oSort['uk_date-asc']  = function(a,b) {
    var re = /(\d{2}\/\d{2}\/\d{4})/;
    a.match(re);
    var ukDatea = RegExp.$1.split("/");
    b.match(re);
    var ukDateb = RegExp.$1.split("/");

    var x = (ukDatea[2] + ukDatea[1] + ukDatea[0]) * 1;
    var y = (ukDateb[2] + ukDateb[1] + ukDateb[0]) * 1;

    return ((x < y) ? -1 : ((x > y) ?  1 : 0));
  };

  jQuery.fn.dataTableExt.oSort['uk_date-desc'] = function(a,b) {
    var re = /(\d{2}\/\d{2}\/\d{4})/;
    a.match(re);
    var ukDatea = RegExp.$1.split("/");
    b.match(re);
    var ukDateb = RegExp.$1.split("/");

    var x = (ukDatea[2] + ukDatea[1] + ukDatea[0]) * 1;
    var y = (ukDateb[2] + ukDateb[1] + ukDateb[0]) * 1;

    return ((x < y) ? 1 : ((x > y) ?  -1 : 0));
  };
}

function dt_overwrite_html_sorting_localeCompare() {
    jQuery.fn.dataTableExt.oSort['html-asc']  = function(a,b) {
        a = a.replace(/<.*?>/g, "").replace(/\s+/g, " ");
        b = b.replace(/<.*?>/g, "").replace(/\s+/g, " ");
        if (typeof(a.localeCompare == "function")) {
           return a.localeCompare(b);
        } else {
           return (a > b) ? 1 : ((a < b) ? -1 : 0);
        }
    };

    jQuery.fn.dataTableExt.oSort['html-desc'] = function(a,b) {
        a = a.replace(/<.*?>/g, "").replace(/\s+/g, " ");
        b = b.replace(/<.*?>/g, "").replace(/\s+/g, " ");
        if(typeof(b.localeCompare == "function")) {
            return b.localeCompare(a);
        } else {
            return (b > a) ? 1 : ((b < a) ? -1 : 0);
        }
    };
}

function dt_overwrite_string_sorting_localeCompare() {
    jQuery.fn.dataTableExt.oSort['string-asc']  = function(a,b) {
        a = a.replace(/<.*?>/g, "").replace(/\s+/g, " ");
        b = b.replace(/<.*?>/g, "").replace(/\s+/g, " ");
        if (typeof(a.localeCompare == "function")) {
           return a.localeCompare(b);
        } else {
           return (a > b) ? 1 : ((a < b) ? -1 : 0);
        }
    };

    jQuery.fn.dataTableExt.oSort['string-desc'] = function(a,b) {
        a = a.replace(/<.*?>/g, "").replace(/\s+/g, " ");
        b = b.replace(/<.*?>/g, "").replace(/\s+/g, " ");
        if(typeof(b.localeCompare == "function")) {
            return b.localeCompare(a);
        } else {
            return (b > a) ? 1 : ((b < a) ? -1 : 0);
        }
    };
}

function dt_add_type_totalcost() {
  function totalcost_sort(a,b) {
    a = a.replace(/\s+/g, " ");
    b = b.replace(/\s+/g, " ");
    var re = /(\d+\.\d+)x(\d+) = (\d+\.\d+) <p.*>(.*)<\/p>/;
    a.match(re);
    var a_ecost = RegExp.$1 * 1;
    var a_qty = RegExp.$2 * 1;
    var a_total = RegExp.$3 * 1;
    var a_budget = RegExp.$4;
    b.match(re);
    var b_ecost = RegExp.$1 * 1;
    var b_qty = RegExp.$2 * 1;
    var b_total = RegExp.$3 * 1;
    var b_budget = RegExp.$4;

    var r = (a_total > b_total) ? 1 : ((a_total < b_total) ? -1 : 0);

    if(r == 0){
      if(typeof(a_budget.localeCompare == "function")){
        r = a_budget.localeCompare(b_budget);
      }else{
        r = (a_budget > b_budget) ? 1 : ((a_budget < b_budget) ? -1 : 0);
      }
    }

    return r;
  }

  jQuery.fn.dataTableExt.oSort['totalcost-asc'] = function(a,b) {
    return totalcost_sort(a,b);
  };

  jQuery.fn.dataTableExt.oSort['totalcost-desc'] = function(a,b) {
    return totalcost_sort(b,a);
  };
}

function dt_add_type_htmlbasketno() {
  function htmlbasketno_sort(a, b) {
    a = a.replace(/\s+/g, " ");
    b = b.replace(/\s+/g, " ");

    var re = /<.*?basketno=.*?>(\d+)<.*?> (.*)/;
    a.match(re);
    var a_basketno = RegExp.$1 * 1;
    var a_string = RegExp.$2.replace(/<.*?>/g, "");
    b.match(re);
    var b_basketno = RegExp.$1 * 1;
    var b_string = RegExp.$2.replace(/<.*?>/g, "");

    var r = (a_basketno > b_basketno) ? 1 : ((a_basketno < b_basketno) ? -1 : 0);

    if(r == 0) {
      if(typeof(a_string.localeCompare == "function")){
        r = a_string.localeCompare(b_string);
      }else{
        r = (a_string > b_string) ? 1 : ((a_string < b_string) ? -1 : 0);
      }
    }

    return r;
  }

  jQuery.fn.dataTableExt.oSort['htmlbasketno-asc'] = function(a,b) {
      return htmlbasketno_sort(a,b);
  };

  jQuery.fn.dataTableExt.oSort['htmlbasketno-desc'] = function(a,b) {
      return htmlbasketno_sort(b,a);
  };
}
