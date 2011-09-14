/* appel ajax pour la recup des sommaires */

//creation de l'instance XMLHttpRequest
function create_xhrtk()
{
 //declaration de la reference à l'objet
 var xhrtk ;
 //code pour les diff versions de navigateurs
 try
  {
   // essai objet XMLHtttpRequest
   xhrtk = new XMLHttpRequest() ;
  }
 catch(e)
  {
   // les versions de IE sous activeX (du plus recent au plus ancien !)
   var xhrtkVersions = new array ('MSXML2.XMLHTTP.6.0',
                                'MSXML2.XMLHTTP.5.0',
								'MSXML2.XMLHTTP.4.0',
								'MSXML2.XMLHTTP.3.0',
								'MSXML2.XMLHTTP',
								'Microfost.XMLHTTP');
   for ( var i = 0 ; i < xhrtkVersions.length && !xhrtk ; i++)
    {
     try
      {
       xhrtk = new ActiveXObject(xhrtkVersions[i]) ;
      }
     catch(e) 
      {} // ignore erreur pour bloucler sur le for
    }
  }
  //renvoie l'objet cree, ou une erreur
  if (!xhrtk)
   { alert ("Probleme : pas de creation de l'objet xhrtk") ; }
  else
   { 
//	 alert ("xhrtk ok") ; 
	return xhrtk ; }
}


// traitement de la réponse
function traitement_reponse()
{
// teste si traitement termine
if (xhrtk.readyState == 4 )
 {
  // teste si statut htm est ok
 //alert ("status "+xhrtk.status) ;
  if ( xhrtk.status == 200 )
   {
    try
     {
      // recupere la reponse
//     reponse = xhrtk.responseText ;
      
	  //puis la met dans un div specif, après avoir vide son contenu

	  var div_rep = document.getElementById("sommaire") ;
	  div_rep.innerHTML=eval(xhrtk.responseText);
     }
    catch(e)
     {
      //affiche un mesage d'erreur
      alert ("Probleme dans la lecture de la reponse :\n" + e.toString() ) ;
     }
   }
  else
   {
    // affiche un message d'erreur
    alert ("Probleme dans la recupération de la reponse :\n" + xhrtk.statusText ) ;
   }
 }
}


function sommaire(isbn) {
//continue uniquement si xhrtk existe
if (xhrtk)
 {
  //tentative de connexion au serveur
  try
   {
    // initialise la requete http asynchrone
    xhrtk.open("GET", "/cgi-bin/koha/recup_toc_koha.php?isbns_n="+isbn, true) ;
    xhrtk.onreadystatechange = traitement_reponse ;
	xhrtk.send(null) ;
   }
  //affiche une message en cas d'erreur
  catch(e) 
   {
    alert ("Probleme envoie requete :\n" + e.toString() ) ;
   }
 }
}

// pour lancer l'appel ajax : 2 temps
// <script type=\"text/javascript\" src=\"toc_koha_ajax.js\"> </script> // qui créer l'objet xhrtk
//puis <script type=\"text/javascript\">sommaire('isbn')</script> // qui utilise ajax pour lancer et recuperer script recup_toc_koha_v1.php

if (!xhrtk) {
	var xhrtk = create_xhrtk() ;
	}
