<?xml version="1.0" encoding="UTF-8"?>
<!--
	FOGLIO DI STILE XSLT PER TRASFORMAZIONE TEI → HTML
	=================================================

	Questo foglio di stile trasforma un documento TEI Roma P5 in una pagina HTML interattiva
	con zone cliccabili che collegano le immagini del manoscritto al testo codificato.

	CARATTERISTICHE:
	- Generazione dinamica di immagini e zone per qualsiasi numero di pagine
	- Creazione di array JavaScript con coordinate delle zone
	- Trasformazione di elementi semantici TEI in HTML con tooltip
	- Gestione di attributi di rendering per styling (indent, center, ecc.)
	- Sincronizzazione ID tra zone XML e elementi HTML per interattività

	COMPONENTI:
	1. Template principale che genera struttura HTML completa
	2. Template per elementi TEI semantici (persName, placeName, ecc.)
	3. Template per gestione complessa delle righe di testo
	4. Generazione di script JavaScript dinamico con coordinate
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">
	<!-- Output HTML con indentazione per leggibilità -->
	<xsl:output method="html" indent="yes"/>
	<!-- Template per nascondere l'elemento availability e il suo contenuto -->
	<xsl:template match="tei:availability">
		<!-- Non processa nulla - ignora completamente l'elemento -->
	</xsl:template>

	<!-- Template per nascondere i paragrafi all'interno di availability -->
	<xsl:template match="tei:availability/tei:p">
		<!-- Non processa nulla - ignora completamente il paragrafo -->
	</xsl:template>
	<xsl:template name="render-metadata-item-new">
		<xsl:param name="label"/>
		<xsl:param name="content"/>
		<div class="description-item">
			<p>
				<xsl:value-of select="$label"/>: <xsl:value-of select="$content"/>
			</p>
		</div>
	</xsl:template>
	<xsl:template name="render-transcriber-link">
		<xsl:param name="label"/>
		<xsl:param name="name-node"/>
		<div class="description-item">
			<p>
				<xsl:value-of select="$label"/>:
				<xsl:choose>
					<xsl:when test="$name-node/@ref or $name-node/@target">
						<a href="{$name-node/@ref | $name-node/@target}" target="_blank">
							<xsl:value-of select="$name-node"/>
						</a>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$name-node"/>
					</xsl:otherwise>
				</xsl:choose>
			</p>
		</div>
	</xsl:template>
	<!--
		TEMPLATE PRINCIPALE - Genera la struttura HTML completa
		Questo template è il punto di ingresso che trasforma il documento TEI in HTML
	-->
	<xsl:template match="/">
		<html lang="it">
			<head>
				<title>Codifica TEI Roma P5</title>
				<link rel="icon" href="favicon.ico"/>
				<meta name="description" content="TEI Roma P5"/>
				<!-- Collegamento al foglio di stile CSS per la presentazione -->
				<link rel="stylesheet" href="tei_transform.css"/>
			</head>
			<body>
				<!-- Sezione di descrizione del documento controllo con pulsanti per l'interfaccia utente -->
				<div class="description-section" role="region" aria-label="Controlli di visualizzazione">

				<xsl:if test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title">
					<h2>
						<xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type='main']"/>
						<xsl:if test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type='sub']">
							<xsl:text> - </xsl:text>
							<xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type='sub']"/>
						</xsl:if>
					</h2>
				</xsl:if>

				<xsl:if test="//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:publisher or //tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:pubPlace or //tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:date">
					<p class="metadata-pub-original">
						<xsl:value-of select="//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:publisher"/>
						<xsl:if test="//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:publisher and (//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:pubPlace or //tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:date)">
							<xsl:text>, </xsl:text>
						</xsl:if>
						<xsl:value-of select="//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:pubPlace"/>
						<xsl:if test="//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:pubPlace and //tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:date">
							<xsl:text>, </xsl:text>
						</xsl:if>
						<xsl:value-of select="//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:date"/>
					</p>
				</xsl:if>

					<xsl:call-template name="render-metadata-item-simple">
						<xsl:with-param name="label">Pagine Codificate</xsl:with-param>
						<xsl:with-param name="content" select="//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:biblScope[@unit='pages']"/>
					</xsl:call-template>

				<xsl:if test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor[@role='founder']">
					<xsl:call-template name="render-metadata-item-new">
						<xsl:with-param name="label">Fondatori</xsl:with-param>
						<xsl:with-param name="content">
							<xsl:for-each select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor[@role='founder']">
								<xsl:value-of select="."/>
								<xsl:if test="position() &lt; last()">
									<xsl:text>, </xsl:text>
								</xsl:if>
							</xsl:for-each>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:if>

				<xsl:if test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:respStmt[tei:resp='Trascrittore']">
					<xsl:call-template name="render-transcriber-link">
						<xsl:with-param name="label">Trascrittore</xsl:with-param>
						<xsl:with-param name="name-node" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:respStmt[tei:resp='Trascrittore']/tei:name"/>
					</xsl:call-template>
				</xsl:if>

				<xsl:if test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:seriesStmt/tei:respStmt[tei:resp='coordinata dal professor']">
					<xsl:call-template name="render-transcriber-link">
						<xsl:with-param name="label">Coordinatore</xsl:with-param>
						<xsl:with-param name="name-node" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:seriesStmt/tei:respStmt[tei:resp='coordinata dal professor']/tei:name"/>
					</xsl:call-template>
				</xsl:if>

					<xsl:call-template name="render-metadata-item-link-simple">
						<xsl:with-param name="label">Progetto Digitale</xsl:with-param>
						<xsl:with-param name="content" select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:ptr/@target"/>
					</xsl:call-template>

					<!-- Container per i pulsanti di controllo -->
					<div class="controls-container">
						<button class="toggle-button" onclick="ToggleHighlights(this)">Nascondi fenomeni notevoli</button>
						<button class="toggle-button margin-left" onclick="ToggleZoneOverlay(this)">Mostra zone</button>
					</div>
				</div>
				<div id="main-container" role="main">
					<!-- Container per le immagini del manoscritto con zone interattive -->
					<div id="image-container" role="region" aria-label="Immagini del testo">
						<h2>Immagini del testo</h2>
						<!-- Container flessibile per organizzare le immagini verticalmente -->
						<div id="images-wrapper">
							<!-- Loop dinamico su tutte le surface (pagine) nel facsimile -->
							<xsl:for-each select="/tei:TEI/tei:facsimile/tei:surface">
								<!-- Wrapper per ogni pagina con posizionamento relativo per overlay -->
								<div class="page-wrapper">
									<!-- Immagine della pagina con ID dinamico basato sulla posizione -->
									<img id="page{position()}-image" src="{./tei:graphic/@url}" alt="Facsimile pagina {position()}" />
									<!-- Image map con aree cliccabili per ogni zona -->
									<map name="page{position()}-map" id="page{position()}-map">
										<!-- Loop su tutte le zone della pagina corrente -->
										<xsl:for-each select="./tei:zone">
											<!-- Area cliccabile con coordinate dalla zona TEI -->
											<area shape="rect" coords="{@ulx},{@uly},{@lrx},{@lry}" alt="Riga di testo" href="javascript:void(0);" data-zone-id="{@xml:id}"/>
										</xsl:for-each>
									</map>
								</div>
							</xsl:for-each>
						</div>
					</div>
					<!-- Container per il testo codificato TEI -->
					<div id="text-container" role="region" aria-label="Testo codificato">
						<h2>Codifica TEI</h2>
						<!-- Area di contenuto con supporto per screen reader -->
						<div id="text-content" aria-live="polite" aria-atomic="false">
							<!-- Applica template per titoli -->
							<xsl:apply-templates select="//tei:head"/>
							<!-- Applica template per paragrafi -->
							<xsl:apply-templates select="//tei:p"/>
							<!-- Applica template per liste dei personaggi -->
							<xsl:apply-templates select="//tei:castList"/>
						</div>
					</div>
				</div>
				<!-- Script JavaScript dinamico generato dall'XSL -->
				<script>
					// Array delle zone generato dinamicamente dall'XSL
					// Contiene tutte le zone di tutte le pagine con le coordinate originali
					// Formato: { id: 'ZN_P1_R1', coords: [ulx, uly, lrx, lry] }
					let zonesData = [
					<!-- Loop su tutte le zone di tutte le pagine -->
					<xsl:for-each select="/tei:TEI/tei:facsimile/tei:surface/tei:zone">
						<!-- Estrae l'ID della zona rimuovendo il prefisso "ZONE_" -->
						<xsl:variable name="zoneId" select="substring-after(@xml:id, 'ZONE_')"/>
						<!-- Estrae le coordinate della zona -->
						<xsl:variable name="ulx" select="@ulx"/>
						<xsl:variable name="uly" select="@uly"/>
						<xsl:variable name="lrx" select="@lrx"/>
						<xsl:variable name="lry" select="@lry"/>
						<!-- Crea oggetto JavaScript con ID e array di coordinate -->
						{ id: '<xsl:value-of select="$zoneId"/>', coords: [<xsl:value-of select="$ulx"/>, <xsl:value-of select="$uly"/>, <xsl:value-of select="$lrx"/>, <xsl:value-of select="$lry"/>] }<xsl:if test="position() != last()">,</xsl:if>
					</xsl:for-each>
					];
				</script>
				<script src="tei_transform.js"></script>
			</body>
		</html>
	</xsl:template>
	<!-- Template per elementi tei:head - Trasforma in titoli H3 -->
	<xsl:template match="tei:head">
		<h3 class="tei-head tei-head-bold-center" id="head-chapter-2">
			<xsl:apply-templates/>
		</h3>
	</xsl:template>

	<!-- Template per segmenti di capitolo - Trasforma in grassetto -->
	<xsl:template match="tei:seg[@type='chapter']">
		<strong><xsl:apply-templates/></strong>
	</xsl:template>

	<!-- Template per paragrafi TEI - Wrapper con classe CSS -->
	<xsl:template match="tei:p">
		<div class="tei-paragraph">
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<!--
		Template per righe di testo (tei:l) - Gestione complessa con logica condizionale
		Distinguisce tra righe di capitolo e righe normali, gestisce attributi di rendering
	-->
	<xsl:template match="tei:l">
		<xsl:choose>
			<!-- Se la riga contiene un segmento di capitolo -->
			<xsl:when test="tei:seg[@type='chapter']">
				<div class="tei-line tei-line-chapter" data-zone="{@facs}" id="{substring-after(@facs, '#')}">
					<span class="chapter-title">
						<xsl:apply-templates/>
					</span>
				</div>
			</xsl:when>
			<!-- Righe normali di testo -->
			<xsl:otherwise>
				<!-- Span per righe normali con attributi per interattività -->
				<span class="tei-line" data-zone="{@facs}" id="{substring-after(@facs, '#')}">
					<!-- Gestione attributi di rendering per styling CSS -->
					<xsl:if test="@rend">
						<xsl:attribute name="class">
							<xsl:text>tei-line </xsl:text>
							<xsl:choose>
								<!-- Mappa attributi TEI a classi CSS -->
								<xsl:when test="@rend = 'indent'">
									<xsl:text>rend-indent</xsl:text>
								</xsl:when>
								<xsl:when test="@rend = 'indent-2'">
									<xsl:text>rend-indent-2</xsl:text>
								</xsl:when>
								<xsl:when test="@rend = 'right'">
									<xsl:text>rend-align-right</xsl:text>
								</xsl:when>
								<xsl:when test="@rend = 'center'">
									<xsl:text>rend-align-center</xsl:text>
								</xsl:when>
								<xsl:when test="@rend = 'center-indent'">
									<xsl:text>rend-center-indent</xsl:text>
								</xsl:when>
							</xsl:choose>
						</xsl:attribute>
					</xsl:if>
					<xsl:apply-templates/>
				</span>
				<!-- Gestione interruzioni di riga basata su attributo rend -->
				<xsl:choose>
					<!-- Nessun br per righe allineate (gestite come block) -->
					<xsl:when test="@rend = 'right' or @rend = 'center' or @rend = 'center-indent'">
						</xsl:when>
					<!-- Br per righe normali -->
					<xsl:otherwise>
						<br/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Template per metadati semplici -->
	<xsl:template name="render-metadata-item-simple">
		<xsl:param name="label"/>
		<xsl:param name="content"/>
		<xsl:if test="$content != '' and normalize-space($content) != ''">
			<div class="description-item">
				<p>
					<xsl:value-of select="$label"/>: <xsl:value-of select="$content"/>
				</p>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template name="render-metadata-item-link-simple">
		<xsl:param name="label"/>
		<xsl:param name="content"/>
		<xsl:param name="link-text"/>
		<xsl:if test="$content != '' and normalize-space($content) != ''">
			<div>
				<xsl:value-of select="$label"/>:
				<a href="{$content}" target="_blank">
					<xsl:value-of select="$content"/>
				</a>
			</div>
		</xsl:if>
	</xsl:template>
	<!-- Template per nomi di persona - Elemento semantico con tooltip -->
	<xsl:template match="tei:persName">
		<span class="persName" title="Nome di persona">
			<xsl:apply-templates/>
		</span>
	</xsl:template>

	<!-- Template per nomi di luogo - Elemento semantico con tooltip -->
	<xsl:template match="tei:placeName">
		<span class="placeName" title="Nome di luogo">
			<xsl:apply-templates/>
		</span>
	</xsl:template>

	<!-- Template per titoli - Elemento semantico con tooltip descrittivo -->
	<xsl:template match="tei:title">
		<span class="title" title="Titolo (opera, sezione, capitolo)">
			<xsl:apply-templates/>
		</span>
	</xsl:template>

	<!-- Template per citazioni - Usa elemento HTML semantico <q> -->
	<xsl:template match="tei:q">
		<q class="quoted-text" title="Citazione o discorso diretto">
			<xsl:apply-templates/>
		</q>
	</xsl:template>

	<!-- Template per termini tecnici - Elemento semantico con tooltip -->
	<xsl:template match="tei:term">
		<span class="term" title="Termine tecnico o specialistico">
			<xsl:apply-templates/>
		</span>
	</xsl:template>

	<!-- Template per enfasi - Usa elemento HTML semantico <em> -->
	<xsl:template match="tei:emph">
		<em class="emph" title="Enfasi o forte evidenziazione">
			<xsl:apply-templates/>
		</em>
	</xsl:template>

	<!-- Template per identificatori di oggetti - Elemento semantico -->
	<xsl:template match="tei:ident">
		<span class="ident" title="Nome di oggetto">
			<xsl:apply-templates/>
		</span>
	</xsl:template>

	<!-- Template per nome proprio - Elemento semantico -->
	<xsl:template match="tei:name">
		<span class="name" title="Nome proprio">
			<xsl:apply-templates/>
		</span>
	</xsl:template>

	<!-- Template per nome di nave - Elemento semantico -->
	<xsl:template match="tei:name[@type='ship']">
		<span class="name" title="Nome di nave">
			<xsl:apply-templates/>
		</span>
	</xsl:template>

	<!-- Template per ruolo - Elemento semantico -->
	<xsl:template match="tei:roleName">
		<span class="rolename" title="Ruolo">
			<xsl:apply-templates/>
		</span>
	</xsl:template>

	<!-- Template per organizzazione - Elemento semantico -->
	<xsl:template match="tei:orgName">
		<span class="orgname" title="Organizzazione">
			<xsl:apply-templates/>
		</span>
	</xsl:template>

	<!-- Template per date - Elemento semantico con tooltip -->
	<xsl:template match="tei:date">
		<span class="date" title="Data">
			<xsl:apply-templates/>
		</span>
	</xsl:template>

	<!-- Template per nomi di paesi - Elemento semantico -->
	<xsl:template match="tei:country">
		<span class="country" title="Nome di uno stato">
			<xsl:apply-templates/>
		</span>
	</xsl:template>

	<!-- Template per esclamazioni - Elemento hi con attributo rend='exclamation' -->
	<xsl:template match="tei:hi[@rend='exclamation']">
		<span class="exclamation" title="Esclamazione">
			<xsl:apply-templates/>
		</span>
	</xsl:template>

	<!-- Template per grassetto - Elemento hi con attributo rend='bold' -->
	<xsl:template match="tei:hi[@rend='bold']">
		<span class="rend-bold">
			<xsl:apply-templates/>
		</span>
	</xsl:template>

	<!-- Template per corsivo - Usa elemento HTML semantico <i> -->
	<xsl:template match="tei:hi[@rend='italic']">
		<i class="rend-italic">
			<xsl:apply-templates/>
		</i>
	</xsl:template>
	<!--
		Template per nodi di testo - Template di fallback
		Questo template cattura tutti i nodi di testo che non hanno template specifici
		e li rende come contenuto HTML semplice
	-->
	<xsl:template match="text()">
		<xsl:value-of select="."/>
	</xsl:template>
</xsl:stylesheet>
