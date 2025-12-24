@Pushd "%~dp0"

:: Esecuzione della validazione tramite il campione dom.Counter
:: -v: abilita validazione
:: -n: abilita namespace (fondamentale per file TEI)
java -cp "F:\Xerces\xercesImpl.jar;F:\Xerces\xml-apis.jar;F:\Xerces\xercesSamples.jar" dom.Counter -v -n "testo.xml"

@Echo.
@Pause

