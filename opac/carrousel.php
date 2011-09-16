<?php
$tag = $_GET['tag'] ; 

// liste dynamique en fonction de se qui existe dan le fichier carrousel.txt
$lignes = file('../koha-tmpl/carrousel/carrousel.txt');
$max = count($lignes) ;
for ($i=0; $i<$max+1; $i++) 
	{
	// attention de bien mettre des " dans explode !!
	$ligne = explode("\t", $lignes[$i]) ; 
	// [0] le nom du fichier [1] isbn_ori [2] la bib [3] la date enregistrement 
	$bibs[] = $ligne[2] ;
	}
$bib_index_code = array_unique ($bibs);
// on obtient la liste des codes bib du fichier //ATTENTION contient une entre vide !!
// il faut maintenant associer code et libelle pour reconstruire la liste
$bib = array(); 
foreach ( $bib_index_code AS $index=>$code )
	{
	switch (trim($code))
		{
		case "BUSANTE" :
		$bib["BUSANTE"] ="BU Santé";
		break;
		case "BUROANNE" :
		$bib["BUROANNE"]="BU Roanne";
		break;
		case "BUSCI" :
		$bib["BUSCI"]="BU Sciences";
		break;
		case "BUDL" :
		$bib["BUDL"]="BU Tréfilerie";
		break;
		case "CENTREDOC" :
		$bib["CENTREDOC"]="Centre Doc Bât. M";
		break;
		case "CERCRID" :
		$bib["CERCRID"]="CERCRID-CERAPSE";
		break;
		case "CILEC" :
		$bib["CILEC"]="CILEC";
		break;
		case "GATELSE" :
		$bib["GATELSE"]="GATE LSE";
		break;
		case "EN3S" :
		$bib["EN3S"]="EN3S";
		break;
		case "ENISE" :
		$bib["ENISE"]="ENISE";
		break;
		case "ENSASE" :
		$bib["ENSASE"]="ENSASE";
		break;
		case "ESC" :
		$bib["ESC"]="ESC";
		break;
		case "IUT" :
		$bib["IUT"]="IUT";
		break;
		case "ENSMSESCG" :
		$bib["ENSMSESCG"]="MINES 13";
		break;
		case "ENSMSE" :
		$bib["ENSMSE"]="MINES 42";
		break;
		case "TSE" :
		$bib["TSE"]="TELECOM SE";
		break;
		default : // notamment pour une entrée vide
		break;
		}
	}
// tri par ordre alpha valeur
asort($bib) ;

// liste fixe
/*
$bib_total_code_lib = array (
"BUMED"=>"BU Médecine",
"BUROANNE"=>"BU Roanne",
"BUSCI"=>"BU Sciences",
"BUDL"=>"BU Tréfilerie",
"CENTREDOC"=>"Centre Doc Bât. M",
"CERCRID"=>"CERCRID-CERAPSE",
"CILEC"=>"CILEC",
"GATELSE"=>"CREUSET-GATE LSE",
"EN3S"=>"EN3S",
"ENISE"=>"ENISE",
"ENSASE"=>"ENSASE",
"ESC"=>"ESC",
"IUT"=>"IUT",
"ENSMSESCG"=>"MINES 13",
"ENSMSE"=>"MINES 42",
"TSE"=>"TELECOM SE" );
*/
?>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="fr">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title></title>
<link rel="stylesheet" type="text/css" href="/opac-tmpl/prog/en/css/opac.css" />
<script language="JavaScript" type="text/javascript" src="/opac-tmpl/prog/en/js/contentflow/contentflow.js" load="white"></script>
<script language="JavaScript" type="text/javascript" src="/opac-tmpl/prog/en/js/contentflow/prototype.js" type="text/javascript"></script>
<script type="text/javascript">
var ajax_cf = new ContentFlow('ajax_cf', {maxItemHeight:280});
<?php
print ("getPictures(".$_GET['n'].",'".$_GET['tag']."');") ;
?>

function addPictures(t){
        var ic = document.getElementById('itemcontainer');
        var is = ic.getElementsByTagName('img');
        for (var i=0; i< is.length; i++) {
            ajax_cf.addItem(is[i], 'center');
        }
}
function getPictures(n, tag) {
    n = parseInt(n);
 //   alert("./getpics.php?n="+n+"&tag="+tag);
    new Ajax.Updater('itemcontainer', "/cgi-bin/koha/getpics.php?n="+n+"&tag="+tag, {
        onComplete: addPictures
    });
    return false;
}
</script>
</head>
<body style="background-color:white;">
Sélection d'ouvrages <select name="tag" onChange="window.location.href='/cgi-bin/koha/carrousel.php?n=0&tag='+this.options[this.selectedIndex].value;">
<option value="">du réseau Brise-es</option>
<?php
foreach ($bib AS $val=>$lib)
	{
	if (trim($tag) == trim($val) ) { print ("<option value=\"".$val."\" selected=\"selected\">".$lib."</option>\n") ; }
	else { print ("<option value=\"".$val."\">".$lib."</option>\n") ; }
	}

?></select><br /><i>(à faire dérouler avec la mollette de la souris ou d'un clic sur une couverture en arrière plan)</i>
<div id="ajax_cf" class="ContentFlow">
    <div class="flow"> </div>

    <div class="scrollbar"><div class="slider"><div class="position"></div></div></div>
</div>
<div id="itemcontainer" style="height: 0px; width: 0px; visibility: hidden"></div>

</body>
</html>
