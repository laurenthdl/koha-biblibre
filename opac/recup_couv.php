<? 
// pour la gestion du proxy differente sur le nouveau serveur (mars 2010)
$opts = array('http' => array('proxy' => 'tcp://161.3.1.42:3128', 'request_fulluri' => true));
$context = stream_context_create($opts);

$tag = $_GET['tag'] ; 

$bib = array (
"TOUTES"=>"toutes les bib",
"BUROANNE"=>"BU Roanne",
"BUSANTE"=>"BU Santé",
"BUSCI"=>"BU Sciences",
"BUDL"=>"BU Tréfilerie",
"CENTREDOC"=>"Centre Doc Bât. M",
"CERCRID"=>"CERCRID-CERAPSE",
"CILEC"=>"CILEC",
"GATELSE"=>"GATE LSE",
"EN3S"=>"EN3S",
"ENISE"=>"ENISE",
"ENSASE"=>"ENSASE",
"ESC"=>"ESC",
"IUT"=>"IUT",
"ENSMSESCG"=>"MINES 13",
"ENSMSE"=>"MINES 42",
"TSE"=>"TELECOM SE" );

$sel_bib = " <select name=\"tag\">" ;
foreach ($bib AS $val=>$lib)
	{
	if (trim($tag) == trim($val) ) { $sel_bib .= "<option value=\"".$val."\" selected=\"selected\">".$lib."</option>\n" ; }
	else { $sel_bib .= "<option value=\"".$val."\">".$lib."</option>\n" ; }
	}
$sel_bib .= "</select> ";

print ("<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />
<title>carrousel Brise-es</title></head><body>");

if ($_POST["isbn"] != '')
	{
//  = validation du formulaire de copie
$isbn = trim($_POST["isbn"]) ;
$isbn_ori = trim($_POST["isbn_ori"]) ;
$url_couv = trim($_POST["url_couv"]) ;
$tag = trim($_POST["tag"]) ;

recup_couv($isbn, $url_couv, $isbn_ori, $tag, $context);
print ("ok !<br />") ;
print ("si vous voulez vérifiez cliquez<a href=\"/carrousel/".$isbn."_couv.jpg\" target=\"_blank\"> ici </a><br />");

	}

if ($_GET["isbn_f"] == '')
	{
// affichage formulaire saisie isbn
print ("<h2>Sélection de couvertures pour alimenter le carrousel de Brise-ES</h2><fieldset style=\"width:350px;\"><legend>saisissez l'isbn 10 ou 13, avec ou sans tiret</legend><form name=\"recup_couv\" method=\"get\" action=\"".$_SERVER['PHP_SELF']."\"><input type=\"text\" name=\"isbn_f\" /> <input type=\"submit\" value=\"voir\" name=\"Rechercher\" /></form></fieldset><br /><br /><form name=\"voir_liste\" method=\"get\" action=\"".$_SERVER['PHP_SELF']."\">voir les couv déjà sélectionnées pour ".$sel_bib." <input type=submit name=\"liste\" value=\"voir\"></form>");
	if($_GET["liste"] == 'voir' )
		{
		// affichage html des couv ayant bib comme tag
		$tag = trim($_GET["tag"]) ;
		$lignes = file('../koha-tmpl/carrousel/carrousel.txt');
		$n= count($lignes) ;
		// Affiche toutes les lignes du tableau comme code HTML, avec les numéros de ligne
		for ($i=0; $i < $n; $i++) 
			{
			// attention de bien mettre des " dans explode !!
			// [0] le nom du fichier [1] isbn [2] la bib [3] la date enregistrement 
			$ligne = explode("\t", $lignes[$i]) ; 
			if ($ligne[2] == $tag || $tag == "TOUTES" )
				{
				$liste_couv .= "<img src=\"/carrousel/".trim($ligne[0])."\" class=\"item\" />\n";
				}
			}
		print ($liste_couv) ;
		}
	print ("</body></html>");

	}
	else
	{

//$isbns = explode(";",$_GET["isbns_n"]) ;
$isbn_ori = trim($_GET["isbn_f"]) ;


$isbn = ereg_replace('-','',$isbn_ori) ;
	
// determination du site
	if (ereg('^9780', $isbn) || ereg('^9781', $isbn) || ereg('^[01]', $isbn) )
		{
		recup_couv_bn($isbn, $bib, $sel_bib, $isbn_ori, $context) ;
		exit();
		}
	else
		{
		recup_couv_amazon($isbn, $bib, $sel_bib, $isbn_ori, $context) ;
		exit();
		}
	}


function recup_couv($isbn, $url_couv, $isbn_ori, $tag, $context)
{
// recopie du fichier image de couv
// ajoute la date du jour pour traitement futur de nettoyage 
// ajoute un code de bib, pour visionnage de ces choix et process d'effacement avancer

$fic_couv= file_get_contents ( $url_couv, false, $context) ;
$fic_image="../koha-tmpl/carrousel/".$isbn."_couv.jpg" ;
$fic_texte=$isbn."_couv.jpg" ;
$h=fopen ($fic_image, 'w');
fwrite($h, $fic_couv);
fclose($h);

$date= date('Ymd');

//alimentation du fichier texte contenant la liste des fichiers image de couv
$h2 = fopen('../koha-tmpl/carrousel/carrousel.txt', 'a');
fwrite($h2, $fic_texte."\t".$isbn_ori."\t".$tag."\t".$date."\n") ;
fclose($h2) ;
}


//-- traitement si isbn13 on recalcul l'isbn10
function recalculisbn10($isbn13) 
{
$isbn_t = preg_replace  ( '/^978/', '', $isbn13 ) ;
$isbn_t = preg_replace  ( '/-/', '', $isbn_t ) ;
//decoupe par caractere
$base = preg_split('//', $isbn_t, -1, PREG_SPLIT_NO_EMPTY) ;
// enlève le dernier caractere
array_pop($base);
$isbn_t = trim(implode($base)) ;

$ponderation = array(10,9,8,7,6,5,4,3,2) ;
$cle = array(0,'x',9,8,7,6,5,4,3,2,1);
$somme = 0 ;

foreach( $base as $key => $value ) 
	{ $somme += $value* $ponderation[$key] ; }

$r = fmod($somme, 11);
$cle_control = $cle[$r] ;
$isbn10 = $isbn_t.trim($cle_control) ;
return $isbn10 ;
}



//-- recherche couv amazon
function recup_couv_amazon($isbn_a, $bib, $sel_bib, $isbn_ori, $context) 
{
// pour l'instant 08-2007 amazon ne fonctionne pas avec un isbn13, 
// isbn13 Ok sur amazon mais pas /product/toc/
// et necessite un isbn sans tiret
//on prend le premier isbn non 978 ou on recalcul celui-ci
//if (!ereg('^978', $isbn_a ) )
if (preg_match('/^978/', $isbn_a ) == 0 )
//preg_match() returns the number of times pattern matches. That will be either 0 times (no match) or 1 time because preg_match() will stop searching after the first match.
	{
	//$isbn = ereg_replace('-','',$isbn_a) ;
	$isbn = preg_replace  ( '/-/', '', $isbn_a ) ;

	}
else
	{
	$isbn = recalculisbn10($isbn_a);
	}

// processus avec recup depuis site web ... intéressant pour les lien feuilleter dans recup sommaire,
//pour juste la couv plus rapide autrement 

/*
$url_amazon = "http://www.amazon.fr/gp/product/toc/".trim($isbn);
//print_r($url_amazon);
//print("<br />");

// test et @ necessaire car si recherche infrutueuse : retour de page 404 personnalise amazon
if ( $page = @file_get_contents(trim($url_amazon), true, $context) ) 
	{

	// attention pas d'espace avant </td> sinon beaucoup plus de truc !! 
	// pertmet a la fois de tester si quelque chose existe (retour de preg_match), et de le mettre dans le tableau $couv
	
	//<td id="prodImageCell" height="300" width="300"><img onload="if (typeof uet == 'function') { uet('af'); }" src="http://g-ecx.images-amazon.com/images/G/08/nav2/dp/no-image-avail-img-map._V23182730_AA300_.gif" id="prodImage"    usemap="#uploadCustImages" border="0" alt="Infections en gynécologie" onmouseover="" /></td>  A NE PAS AFFICHER
	
	//<td id="prodImageCell" height="300" width="300"><a href="http://www.amazon.fr/gp/product/images/2746041898/ref=dp_image_0?ie=UTF8&n=301061&s=books" target="AmazonHelp" onclick="return amz_js_PopWin(this.href,'AmazonHelp','width=700,height=600,resizable=1,scrollbars=1,toolbar=1,status=1');"  ><img onload="if (typeof uet == 'function') { uet('af'); }" src="http://ecx.images-amazon.com/images/I/51IJlyDz7oL._SL500_PIsitb-sticker-arrow-big,TopRight,35,-73_OU08_AA300_.jpg" id="prodImage"  width="300" height="300"   border="0" alt="Active Directory sous Windows Server 2008" onmouseover="" /></a></td>  OK

	// /s pour les saut de ligne (sinon /r?/n mais on doit connaitre le nombre exacte
	// /U pour que le grep ne soit pas gourmand ! (premiere occurrence
	// /i pour insensible a la casse

	if( preg_match('|<td id="prodImageCell" .* src="(http:\/\/.*)" id=|iU', $page, $couv) == 1 && preg_match('|no-image-avail|i', $page) == 0 )
		{
			
echo "(";	print_r($couv[1]) ; echo ")<br />";
			$url_couv = $couv[1] ;
			$img_couv = "<img src=\"".$couv[1]."\">\n";

		print($img_couv."<br />");
		
		print("<form name=\"couv_ok\" method=\"post\" action=\"".$_SERVER['PHP_SELF']."\"><input type=\"hidden\" name=\"url_couv\" value=\"".$url_couv."\"><input type=\"hidden\" name=\"isbn\" value=\"".$isbn."\"><input type=\"hidden\" name=\"isbn_ori\" value=\"".$isbn_ori."\">Conserver cette couverture ? <input type=\"submit\" name=\"ok\" value=\"oui\"> (".$bib.") / <a href=\"".$_SERVER['PHP_SELF']."\">non</a></form>") ;

		
		}
	else
		{
		print("Désolé, pas trouver de couverture") ;
		}
	}
else
	{
	print("Désolé, pas de réponse") ;
	}

*/
// seconde voie plus rapide mais seulement petite ou grande vignette, pas de moyenne comme sur site
// voire http://aaugh.com/imageabuse.html
//http://images.amazon.com/images/P/0971633894.01._SY300_SCLZZZZZZ_.jpg

$url_amazon = "http://images.amazon.com/images/P/".trim($isbn).".08._SY300_SCLZZZZZZZ_.jpg" ;
if ( $page = @file_get_contents(trim($url_amazon), true, $context) ) 
	{
	echo "(";	print_r($url_amazon) ; echo ")<br />";
			$url_couv = $url_amazon ;
			$img_couv = "<img src=\"".$url_couv."\">\n";

	print($img_couv."<br />");
	
		print("<form name=\"couv_ok\" method=\"post\" action=\"".$_SERVER['PHP_SELF']."\"><input type=\"hidden\" name=\"url_couv\" value=\"".$url_couv."\"><input type=\"hidden\" name=\"isbn\" value=\"".$isbn."\"><input type=\"hidden\" name=\"isbn_ori\" value=\"".$isbn_ori."\">Conserver cette couverture ? (".$sel_bib.") <input type=\"submit\" name=\"ok\" value=\"oui\"> / <a href=\"".$_SERVER['PHP_SELF']."\">non</a></form>") ;
	}
else
	{
	print("Désolé, pas de réponse") ;
	}

} // fin recup_couv_amazon




//-- recup toc B&N
function recup_couv_bn($isbn_bn, $bib, $sel_bib, $isbn_ori, $context) 
{
//modif $url_bn = "http://search.barnesandnoble.com/booksearch/isbninquiry.asp?ISBN=".trim($isbn_bn);
$url_bn = "http://search.barnesandnoble.com/books/product.aspx?ean=".trim($isbn_bn);
// test et @ necessaire car si recherche infrutueuse : retour de page 404 personnalise amazon
if ( $page = @file_get_contents(trim($url_bn), true, $context) ) 
	{
//modif	$page = preg_replace('/(<div id="outer-wrap">)/i', '£$1', $page);
	$page = preg_replace('/(<div id=)/i', '£$1', $page);
	$tab1 = explode("£", $page) ;
//	print_r($tab1);

//modif
	$maxEntre = count($tab1) ;
	for ($div=9; $div < $maxEntre ; $div++ )	// a priori rien d'interessant avant le "18ieme" <div id= - modif le 20101213 image en 11iem place !!
		{
	$donnees = $tab1[$div] ;

//modif	if ( eregi ("We did not find any results", $tab1[1] ) )
		if ( preg_match ('|We did not find any results|i', $donnees) ==1  ) 
  			{
			print ("désolez pas de couv !");
			}
		if ( preg_match ('|id="product-image"|i', $donnees) ==1  ) 
			{
			$tab_couv = explode("<", $donnees) ;
			$maxEntre2 = count($tab_couv) ;
			for ( $ligne2 = 0; $ligne2 < $maxEntre2; $ligne2++) 
				{
				if ( preg_match ('|img .* src="(.*imagesbn.*)"|iU', $tab_couv[$ligne2], $couv ) == 1 ) //  attention aux "Cover Image" : pb des petites imagettes ex : http://search.barnesandnoble.com/JavaScript/David-Flanagan/e/9780596101992/?pwb=1
					{ // couv
					

					echo "(";	print_r($couv[1]) ; echo ")<br />";

					$url_couv = $couv[1] ;
					$img_couv = "<img src=\"".$couv[1]."\">\n";
					$isbn = trim($isbn_bn);
					print($img_couv."<br />");

					print("<form name=\"couv_ok\" method=\"post\" action=\"".$_SERVER['PHP_SELF']."\"><input type=\"hidden\" name=\"url_couv\" value=\"".$url_couv."\"><input type=\"hidden\" name=\"isbn\" value=\"".$isbn."\"><input type=\"hidden\" name=\"isbn_ori\" value=\"".$isbn_ori."\">Conserver cette couverture ? (".$sel_bib.") <input type=\"submit\" name=\"ok\" value=\"oui\"> / <a href=\"".$_SERVER['PHP_SELF']."\">non</a></form>") ;

					}
				} // fin du for $ligne2
			}

		} // fin du for $div

	} // fin du if $apge
else
	{
	print ("désolez pas de réponse");
	}
} //fin de recup_toc_bn


?>
