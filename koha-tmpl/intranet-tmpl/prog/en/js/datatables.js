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
