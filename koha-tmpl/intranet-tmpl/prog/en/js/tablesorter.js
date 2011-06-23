function getTextExtractor( text ) {
    var patternLetters = /[öäüÖÄÜáàâéèêúùûóòôÁÀÂÉÈÊÚÙÛÓÒÔß]/g;
    var lookupLetters = {
      "ä": "a", "ö": "o", "ü": "u",
      "Ä": "A", "Ö": "O", "Ü": "U",
      "á": "a", "à": "a", "â": "a",
      "é": "e", "è": "e", "ê": "e",
      "ú": "u", "ù": "u", "û": "u",
      "ó": "o", "ò": "o", "ô": "o",
      "Á": "A", "À": "A", "Â": "A",
      "É": "E", "È": "E", "Ê": "E",
      "Ú": "U", "Ù": "U", "Û": "U",
      "Ó": "O", "Ò": "O", "Ô": "O",
      "ß": "s"
    };
    var letterTranslator = function(match) { 
      return lookupLetters[match] || match;
    }

    return text.replace(patternLetters, letterTranslator);
}
