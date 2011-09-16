<? 
// script de recherche de sommaire (couv, somaire et 4ieme de couv) sur des sites de librarires en ligne
// pour l'opac koha
// plus d'image de couv,
// et le fichier n'est pas un doc html indépendat mais une partie de code tml qui va s'inserer dans la page avec showbox
// pour l'instant amazone ou barnes & noble
// le choix s'opere sur l'indice de langue de l'isbn (10 ou 13) : 0 ou 1 : B&N, le reste Amazon.fr

//  /recup_toc_koha_v1.php?isbns_n=2701143624;

// pour la gestion du proxy differente sur le nouveau serveur (mars 2010)
$opts = array('http' => array('proxy' => 'tcp://161.3.1.42:3128', 'request_fulluri' => true));
$context = stream_context_create($opts);


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



//-- recherche toc amazon
function recup_toc_amazon($isbn_a, $context) 
{
//$t0= microtime(true);

$sommaire_ok = "
document.getElementById('sommaire_ok').style.display='inline';
document.getElementById('sommaire').style.display='none';
";

$sommaire_non = "document.getElementById('sommaire').style.display='none';" ;


// pour l'instant 08-2007 amazon ne fonctionne pas avec un isbn13, 
// isbn13 Ok sur amazon mais pas /product/toc/
// et necessite un isbn sans tiret
//on prend le premier isbn non 978 ou on recalcul celui-ci
//if (!ereg('^978', $isbn_a ) )
if (preg_match('/^978/', $isbn_a ) == 0 )
	{
	$isbn = preg_replace  ( '/-/', '', $isbn_a ) ;
	}
else
	{
	$isbn = recalculisbn10($isbn_a);
	}

// on teste si on a pas déjà ces fichiers sous la main (i.e. la recherche a deaj ete faite plus tot dans la journée)
$fichier_s = "../koha-tmpl/sommaires/toc/".$isbn.".htm" ;
if ( file_exists($fichier_s) )
	{
//	envoi des lignes de commandes javascript
	print($sommaire_ok);
//	print("\n<a href=\"/sommaires/toc/".trim($isbn).".htm\" rel=\"shadowbox;width=500;height=550\"><img src=\"/sommaires/en_savoir_plus.jpg\" title=\"en savoir plus\"></a>");
	exit();
	}

$fichier_sn = "../koha-tmpl/sommaires/toc_negatif/".$isbn.".htm" ;
if ( file_exists($fichier_sn) )
	{
	print($sommaire_non); // attention ajax evalue la reponse
	exit();
	}

// si on a pas déjà la réponse on va la chercher

$i = 0;
$extrait = 0 ;
$info = 0 ;
$toc =0 ;
$en_tete = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">
<html>
<head>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=ISO-8859-1\">
<title>sommaire</title>
<link href=\"/opac-tmpl/prog/en/css/sommaires_a.css\" rel=\"stylesheet\" type=\"text/css\" />
</head>
<body>" ;
$debut = "<span class=\"sommaire\">" ;
$fin = "</span>";
$pied = "</body></html>";

$url_amazon = "http://www.amazon.fr/gp/product/toc/".trim($isbn);

// test et @ necessaire car si recherche infrutueuse : retour de page 404 personnalise amazon
if ( $page = @file_get_contents(trim($url_amazon), true, $context) ) 
	{
	// preg_match() returns the number of times pattern matches. That will be either 0 times (no match) or 1 time because preg_match() will stop searching after the first match.
	// permet a la fois de tester si quelque chose existe (retour de preg_match), et de le mettre dans le tableau $couv
	// /s pour les saut de ligne (sinon /r?/n mais on doit connaitre le nombre exacte
	// /U pour que le grep ne soit pas gourmand ! (premiere occurrence
	// /i pour insensible a la casse
	if ( preg_match('|<div class="bucket">(.*)</div>|isU', $page, $som) == 1 )
		{
		$toc++ ;
		// $som[1] est utilise plus loin

		}


	// url de l'autre page
	//<a href="http://www.amazon.fr/Citrix-XenApp-Concepts-virtualisation-dapplication/dp/274604675X/ref=dp_return_1?ie=UTF8&amp;n=301061&amp;s=books">Retourner à l'aperçu du produit</a>
	preg_match('|href="(http.*)">.*Retourner .* du produit</a>|iU', $page, $page2);
	$url_desc = $page2[1] ;


//$t1= microtime(true);
	$extrait = 0 ;
	if ( $page2 = @file_get_contents(trim($url_desc), true, $context ) ) 
		{

		if ( preg_match('|(<h2>Descriptions du produit</h2>.*<div class="emptyClear"> </div>)|is', $page2, $desc) == 1 )
			{
//			print_r ($desc);
			$info++ ;
			}
		if ( preg_match('|<b>(Parcourir les pages .chantillon</b>.*)<div class="spacer"></div>|isU', $page2, $feuilleter) == 1 )
			{
			$feuilleter[1] = preg_replace('|href="/gp/reader/|', 'target="_blank" id="extrait" href="http://www.amazon.fr/gp/reader/', $feuilleter[1])  ;
			$feuilleter[1] .= "\n<br /><br />"  ;
			//echo $feuilleter[1]."\n<br />";
			$extrait++ ;
			}
//$t2= microtime(true);
//echo "<hr>".$t0."\n<br />".$t1."\n<br />".$t2 ;
/*
print_r($toc);
print("\n<br />") ;
print_r($som[1]);
print("\n<br />") ;

print_r($info);
print("\n<br />") ;
print_r($desc[1]);
print("\n<br />") ;

print_r($extrait);
print("\n<br />") ;
print_r($feuilleter[1]);
print("\n<br />") ;
*/

	

		if ($toc != 0 || $info != 0 || $extrait != 0)
			{
			$cop = "&copy; <a href=\"".$url_desc."\" target=\"_blank\">Infos r&eacute;cup&eacute;r&eacute;es sur le site de amazon.fr</a>" ;
			$texte = $en_tete."\n".$debut."\n<br />".$feuilleter[1]."\n".$som[1]."<br />".$desc[1]."\n<br />".$feuilleter[1].$cop.$fin.$pied ;
	
			//	envoi le code du logo "en savoir plus" avec le lien sur le fichier a ajax qui va le faire apparraitre dans le span id=sommaire
//			print("\n<a href=\"/sommaires/toc/".trim($isbn).".htm\" rel=\"shadowbox;width=500;height=550\"><img src=\"/sommaires/en_savoir_plus.jpg\" title=\"en savoir plus\"></a>");
			print($sommaire_ok);
			flush ();
			// puis écrit le fichier
			$fichier_s = "../koha-tmpl/sommaires/toc/".$isbn.".htm" ;
			$p = fopen($fichier_s, w);
			fputs($p, $texte) ;
			fclose($p) ;
			exit(); 
			} 

		else // cas ou $toc == 0 && $info == 0 && $extrait ==0 
			{
			$cop = "&copy; <a href=\"".$url_desc."\" target=\"_blank\">amazon.fr</a>" ;
			$texte = $en_tete."pas d'information disponible<br />".$cop.$pied ;
			print($sommaire_non) ; // pour ajax qui évalue la réponse
			flush ();

			$fichier_sn = "../koha-tmpl/sommaires/toc_negatif/".$isbn.".htm" ;
			$n = fopen($fichier_sn, w);
			fputs($n, $texte) ;
			fclose($n) ;
			exit() ;
			}

		}//fin du if ( $page2 = @file_get_contents(trim($url_desc)) ) 

	} // fin du if $page
else // du if $page
	{
	$cop = "&copy; <a href=\"http://www.amazon.fr\" target=\"_blank\">amazon.fr</a>" ;
	$texte = $en_tete.$debut."D&eacute;sol&eacute;, recherche infructueuse<br />".$cop.$fin.$pied ;

print($sommaire_non) ; //pour ajax aui evalue la reponse
flush ();

$fichier_sn = "../koha-tmpl/sommaires/toc_negatif/".$isbn.".htm" ;
$n = fopen($fichier_sn, w);
fputs($n, $texte) ;
fclose($n) ;
exit();
	}

} // recup_toc_amazon



//-- recup toc B&N
function recup_toc_bn($isbn_bn, $context) 
{
//$t0= microtime(true);

$sommaire_ok = "
document.getElementById('sommaire_ok').style.display='inline';
document.getElementById('sommaire').style.display='none';
";

$sommaire_non = "document.getElementById('sommaire').style.display='none';" ;

// suite modif code source des pages BN en attendant refonte du script
print ($sommaire_non) ;
exit();

$fichier_s = "../koha-tmpl/sommaires/toc/".$isbn_bn.".htm" ;
if ( file_exists($fichier_s) )
	{
//	envoi des lignes de commandes javascript
	print($sommaire_ok);
	exit();
	}

$fichier_sn = "../koha-tmpl/sommaires/toc_negatif/".$isbn_bn.".htm" ;
if ( file_exists($fichier_sn) )
	{
	print($sommaire_non); // attention ajax evalue la reponse
	exit();
	}

$couv = "" ;
$see_inside = "";
$toc = "" ;
$desc = "" ;
$i = 0;
$extrait = "" ;
$en_tete = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">
<html>
<head>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=ISO-8859-1\">
<title>sommaire</title>
<link href=\"/opac-tmpl/prog/en/css/sommaires_bn.css\" rel=\"stylesheet\" type=\"text/css\" />
</head>
<body>" ;
$debut = "<span class=\"sommaire\">" ;
$fin = "</span>";
$pied = "</body></html>";

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
		if ( preg_match ('/We did not find any results/i', $donnees) ==1  ) 
  			{
			print($sommaire_non) ; // pour ajax qui évalue la réponse
			flush ();
			$cop = "&copy; <a href=\"http://www.barnesandnoble.com/\" target=\"_blank\">Barnesandnoble.com</a>" ;
			$texte = $en_tete.$debut."D&eacute;sol&eacute;, recherche infructueuse<br />".$cop.$fin.$pied ;
//		print($texte) ;
		$fichier_sn = "../koha-tmpl/sommaires/toc_negatif/".$isbn_bn.".htm" ;
		$n = fopen($fichier_sn, w);
		fputs($n, $texte) ;
		fclose($n) ;
		exit();
			}

			if ( preg_match ('/id="product-image"/i', $donnees) ==1  ) 
				{
				$tab_couv = explode("<", $donnees) ;
				$maxEntre2 = count($tab_couv) ;
				for ( $ligne2 = 0; $ligne2 < $maxEntre2; $ligne2++) 
					{

					if ( preg_match ('/title="See Inside/i', $tab_couv[$ligne2]) == 1 )
						{ // lien et image "see inside" // mais manque les < ouvrant a href et img
						$see_inside .= "<".trim($tab_couv[$ligne2]) ;
						}
					}  // fin du for ligne2
				$see_inside .="</a>" ;
//print("<hr><br />see inside<br />");
//print_r($see_inside);
				}

//modif dans overview on ne garde que la bio et l'annoation, les reviews seront intégralement extraites du div tab-edreviews			
			if ( preg_match ('/id="tab-overview"/i', $donnees) ==1  ) 
				{
				$donnees = preg_replace('/<h/i', '£<h', $donnees) ;
				$tab_desc = explode("£", $donnees) ;
				$maxEntre2 = count($tab_desc) ;
				for ( $ligne2 = 0; $ligne2 < $maxEntre2; $ligne2++) 
					{ // attention "from the publisher par toujours dans le meme "tab"
//					if ( preg_match ('#<h3>Synopsis</h3>#i', $tab_desc[$ligne2]) == 1 || 
//						preg_match ('#<h3>From the Publisher</h3>#i', $tab_desc[$ligne2]) == 1 || 
//						preg_match ('#<h3>Biography</h3>#i', $tab_desc[$ligne2]) == 1  ||  
//						preg_match ('#<h3>Annotation</h3>#i', $tab_desc[$ligne2]) == 1 )
					if ( preg_match ('#<h3>Biography</h3>#i', $tab_desc[$ligne2]) == 1  ||  
						preg_match ('#<h3>Annotation</h3>#i', $tab_desc[$ligne2]) == 1 )

					$desc .= $tab_desc[$ligne2] ;
					}
				$desc = preg_replace('#<a name=".*</a>#iU', '', $desc) ;
				// pour enlever les liens du type <a name="moreReviewsContentTrigger_6" onclick="javascript:openTab('edreviews')" href="#TABS" class="left-arrow-small">More Reviews and Recommendations</a>
				$desc = strip_tags($desc, '<p><br><h1><h2><h3><h4><h5><h6><strong><ul><li><script>');
//print("<hr><br />desc tab-overview<br />");
//print_r($desc);
				}

			if ( preg_match ('/tab-edreviews"/i', $donnees) ==1  ) 	   // on garde toutes les reviews (ed, b&n et autres revues)
				{
					$desc .= $donnees ;
				// pour enlever les liens du type <a name="moreReviewsContentTrigger_6" onclick="javascript:openTab('edreviews')" href="#TABS" class="left-arrow-small">More Reviews and Recommendations</a>
				$desc = preg_replace('#<a name=".*</a>#iU', '', $desc) ;
				$desc = strip_tags($desc, '<p><br><h1><h2><h3><h4><h5><h6><strong><ul><li><script>');
//print("<hr><br />desc tab-edreviews<br />");
//print_r($desc);
				}
		
//modif			
			if (  preg_match ('/id="exc"/i', $donnees) == 1 )	// NB l'extrait n'est plus dans le div 	id="tab-features" mais dans le div suivant div id="exc"
				{
					$extrait =  "<h3> Read an Excerpt </h3>".$donnees ;
					$extrait = strip_tags($extrait, '<p><br><h1><h2><h3><h4><h5><h6><strong><ul><li><pre><blockquote><script>');
					$extrait = preg_replace('#<a name=".*</a>#iU', '', $extrait) ;
//print("<hr><br />desc tab-features<br />");
//print_r($extrait);
				}
			if (  preg_match ('/ id="toc"/i', $donnees) == 1 ) // NB les toc ne sont pas dans id="tab-features compte tenu du découpage
				{
				$toc = "<h3>Table of Contents</h3>".$donnees ;
				$toc = preg_replace('/ style="font-size: 10px;"/', "", $toc) ;
				$toc = strip_tags($toc, '<p><br><h1><h2><h3><h4><h5><h6><strong><table><tr><td><dl><dt><ul><li><script>');

				// modif sommaire positif	
				$presence_toc = "oui" ;
//print("<hr><br />desc toc<br />");
//print_r($toc);
				}


			
//			} // fin du for $ligne
		} // fin du for $div
	
		$info = 0 ;
// plus de recup de couv
//		if (trim($couv) == ""  )
//			{ $couv = "<i>pas d'image de couverture disponible</i>"; }
//		else { $info++ ; }
		if (trim($toc) == "" && $see_inside == "</a>")  //on peut ne pas avoir de toc, mais l'obtenir via le see inside
		// exemple http://search.barnesandnoble.com/books/product.aspx?ean=9780060503000
			{$toc = "<br /><i>pas de sommaire disponible</i>"; }
		else { $info++ ; }
		if (trim($desc) == "" && trim($extrait) == "") 
			{$desc = "<br /><i>pas de description par l'&eacute;diteur disponible</i>"; }
		else { $info++ ; }

		if ( $info != 0 ) // il y a au moins une info
			{

			$cop = "&copy; <a href=\"".$url_bn."\" target=\"_blank\">Infos r&eacute;cup&eacute;r&eacute;es sur le site Barnesandnoble.com</a>" ;
			$texte = $en_tete.$debut."\n".$see_inside."<br />\n".$toc."\n".$extrait."\n".$desc."\n".$biogr."\n".$cop.$fin.$pied ;

//				print($texte) ;
			print($sommaire_ok);
				flush();
				$fichier_s = "../koha-tmpl/sommaires/toc/".$isbn_bn.".htm" ;
				$f = fopen($fichier_s, w);
				fputs($f, $texte) ;
				fclose($f) ;

			}
		else // il n'y a pas d'info 
			{
			$cop = "&copy; <a href=\"http://www.barnesandnoble.com/\" target=\"_blank\">Barnesandnoble.com</a>" ;
			$texte = $en_tete.$debut."D&eacute;sol&eacute;,<br />ni image de couverture ni sommaire disponible<br />".$cop.$fin.$pied ;
print($sommaire_non) ; 
flush();

$fichier_sn = "../koha-tmpl/sommaires/toc_negatif/".$isbn_bn.".htm" ;
$n = fopen($fichier_sn, w);
fputs($n, $texte) ;
fclose($n) ;
			} 

//		} // fin else sur reponse ou pas 
	} // fin du page
else // du if $page
	{
	$cop = "&copy; <a href=\"http://www.barnesandnoble.com\" target=\"_blank\">Barnesandnoble.com</a>" ;
	$texte = $en_tete.$debut."D&eacute;sol&eacute;, recherche infructueuse<br />".$cop.$fin.$pied ;
print($sommaire_non) ;
flush();

$fichier_sn = "../koha-tmpl/sommaires/toc_negatif/".$isbn_bn.".htm" ;
$n = fopen($fichier_sn, w);
fputs($n, $texte) ;
fclose($n) ;
	}
//$t2=microtime(true);
//echo "<hr>".$t0."\n<br />".$t1."\n<br />".$t2 ;

//print($book) ; // mis avant l'écriture des fichier pour gagner un peu de temps d'affichage

exit();
} //fin de recup_toc_bn


$isbns = explode(";",$_GET["isbns_n"]) ;
$isbn ="";

//on prend le premier isbn non 978 ou on recalcul celui-ci
foreach ($isbns as $cle=>$donnee)
	{
	if ($donnee != "") // au moins un isbn
		{
		$isbn = ereg_replace('-','',$donnee) ;
		break ;
		}
	}
	
if ( $isbn == "")
	{
	// si il n'y a pas d'isbn (utilise pour fermer popup si pas d'isbn), bien que ne devrait pas etre utile
	print($sommaire_non) ;
	exit() ;
	}
else
	{
	// determination du site
	if (ereg('^9780', $isbn) || ereg('^9781', $isbn) || ereg('^[01]', $isbn) )
		{
		recup_toc_bn($isbn, $context) ;
		exit();
		}
	else
		{
		recup_toc_amazon($isbn, $context) ;
		exit();
		}
	}

?>
