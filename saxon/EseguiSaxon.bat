@Pushd "%~dp0"
@Rem java -jar F:\SaxonHE\saxon-he-12.9.jar -s:testo.xml -xsl:tei_transform.xsl -o:output.html --standardErrorOutputFile:errori.txt
java -jar F:\SaxonHE\saxon-he-12.9.jar -s:testo.xml -xsl:tei_transform.xsl -o:index.html
@Pause
