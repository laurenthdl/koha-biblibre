

/*
Prepare the select options before search.
*/
/*
Print select box option with authorised values of the list related to the index choosen.
*/
function getAuthorisedValuesList (select) {
  var index  = $(select).find("option:selected").val ();
  var avlist = $(select).find("option:selected").attr ("avlist");
  $(select).parent().find('.avlist').empty();
  if (avlist) {
    $.getJSON("/cgi-bin/koha/services/avservice.pl?op=get_av&index=" + index,
      function (data,status) {
           var str = '<select name="q">';
           $.each(data.av, function(key, value) {
             str += "<option value="+ value.authorised_value +">"+ value.lib +"</option>";
          });
          str += "</select>";
          $(select).parent().find('input[name="q"]:first').attr('disabled','disabled');
          $(select).parent().find('input[name="q"]:first').hide();
          $(select).parent().find('.avlist').append(str);
    });
  } 
  else {
          $(select).parent().find('input[name="q"]:first').removeAttr('disabled');
          $(select).parent().find('input[name="q"]:first').show();
  }
}
