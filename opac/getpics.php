<?php
//script repondant a l'appel ajax du carrousel
// doit retourner les infos des notices stocker sous la forme 
/*
<a class="item" href="YOUR_URL"><img src="pics/pic53.jpg" class="content" /></a>
<a class="item" href="YOUR_URL"><img src="pics/pic55.jpg" class="content" /></a>
<a class="item" href="YOUR_URL"><img src="pics/pic51.jpg" class="content" /></a>
*/
//le fichier à lire est carrousel.txt

//il se présente sous la forme

/*
9780201616224_couv.jpg	9780201616224	creuset	20110222
9780974514086_couv.jpg	9780974514086	ensmse	20110222
9780201835953_couv.jpg	9780201835953	budl_pole_shs	20110222
*/

// l'url requete pour koha avec l'isbn est
//http://161.3.12.90/cgi-bin/koha/opac-search.pl?idx=nb&q=ISBN&limit=
// pour simplifier on reprend le nom de l'exemple getpics.php avec ?n=n
// envoi de la requete en post et retourne exactement ce qu'il y a au-dessus


if ($_GET["n"] != '0' )
{
$reponse ="" ;
$n = $_GET["n"] ;
$lignes = file('../koha-tmpl/carrousel/carrousel.txt');
//le fichier étant de type append : on a les plus anciennces d'abord
//pour avoir les plus récente d'abord au risque quel disparaissent trop vite
$lignes_r = array_reverse($lignes) ;
//print_r($lignes_r);

// Affiche toutes les lignes du tableau comme code HTML, avec les numéros de ligne
for ($i=0; $i<$n; $i++) 
	{
	// attention de bien mettre des " dans explode !!
	$ligne = explode("\t", $lignes_r[$i]) ; 
	// [0] le nom du fichier [1] isbn_ori [2] la bib [3] la date enregistrement 
//	$reponse .= "<a class=\"item\" href=\"http://161.3.12.90/cgi-bin/koha/opac-search.pl?idx=nb&q=".trim($ligne[1])."&limit=\"><img src=\"".trim($ligne[0])."\" class=\"content\" /></a>\n";
	$reponse .= "<img class=\"item\" href=\"/opac-search.pl?idx=nb&q=".trim($ligne[1])."&limit=\" src=\"/carrousel/".trim($ligne[0])."\" target=\"_top\" />\n";
	}
print_r($reponse);
}
if ($_GET["tag"] != '' )
{
$reponse ="" ;
$tag = $_GET["tag"] ;
$lignes = file('../koha-tmpl/carrousel/carrousel.txt');
$n=count($lignes) ;

//le fichier étant de type append : on a les plus anciennces d'abord
//pour avoir les plus récente d'abord au risque quel disparaissent trop vite
$lignes_r = array_reverse($lignes) ;
print_r($lignes_r);

// Affiche toutes les lignes du tableau comme code HTML, avec les numéros de ligne
for ($i=0; $i<$n; $i++) 
	{
		// attention de bien mettre des " dans explode !!
	$ligne = explode("\t", $lignes_r[$i]) ; 
	// [0] le nom du fichier [1] isbn [2] la bib [3] la date enregistrement 
	if ($ligne[2] == $tag )
	{
	//	$reponse .= "<a class=\"item\" href=\"http://161.3.12.90/cgi-bin/koha/opac-search.pl?idx=nb&q=".trim($ligne[1])."&limit=\"><img src=\"".trim($ligne[0])."\" class=\"content\" /></a>\n";
		$reponse .= "<img class=\"item\" href=\"/opac-search.pl?idx=nb&q=".trim($ligne[1])."&limit=\" src=\"/carrousel/".trim($ligne[0])."\" target=\"_top\" />\n";
	}
	}
print_r($reponse);
}

exit() ;
?>
