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
				<!-- Foglio di stile CSS incorporato -->
				<style><xsl:text disable-output-escaping="yes">
				/* Stili di base per il corpo della pagina */
				body
				{
					font-family: Arial, sans-serif;
					margin: 0;
					padding: 10px 10px;
					background-color: #f4f4f4;
					min-height: 100vh;
					box-sizing: border-box;
				}

				/* Sezione di descrizione e controlli */
				.description-section
				{
					background: #f8f9fa;
					border: 1px solid #dee2e6;
					border-radius: 8px;
					padding: 8px;
					margin: 0 auto;
					max-width: 1600px;
					text-align: center;
					box-sizing: border-box;
				}

				/* Container per i controlli */
				.controls-container
				{
					margin-top: 10px;
					padding-top: 5px;
					border-top: 1px solid #dee2e6;
				}

				.description-section h3
				{
					margin-top: 0;
					padding-bottom: 5px;
				}

				/* Paragrafo sotto l'h2 principale */
				.metadata-pub-original
				{
					margin: 0;
				}

				/* Container principale con layout a due colonne */
				#main-container
				{
					display: flex;
					gap: 20px;
					max-width: 1600px;
					margin: 0 auto;
					background: #fff;
					padding: 10px;
					border-radius: 8px;
					box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
					box-sizing: border-box;
					min-height: 300px;
					height: calc(100vh - 200px);
				}

				/* Container per immagini e testo con layout flessibile */
				#image-container, #text-container
				{
					flex: 1;
					min-width: 0;
					border: 1px solid #ddd;
					padding: 15px;
					border-radius: 6px;
					height: 100%;
					overflow-y: auto;
					overflow-x: hidden;
					box-sizing: border-box;
				}

				/* Immagini responsive nelle zone interattive */
				#image-container img
				{
					max-width: 100%;
					width: 100%;
					height: auto;
					display: block;
					border-radius: 4px;
				}

				#images-wrapper
				{
					display: flex;
					flex-direction: column;
					gap: 20px;
				}

				.page-wrapper
				{
					position: relative;
					display: inline-block;
				}

				/* Titoli delle sezioni principali */
				h2
				{
					color: #333;
					border-bottom: 2px solid #eee;
					padding-bottom: 5px;
					margin-top: 0;
					text-align: center;
				}

				/* Titoli TEI per le sezioni del testo */
				h3.tei-head
				{
					color: #555;
					text-align: center;
					margin-bottom: 15px;
					font-size: 1.2em;
				}

				/* Classe per titoli in grassetto e centrati */
				.tei-head-bold-center
				{
					font-weight: bold;
					text-align: center;
				}

				/* Titoli dei capitoli con styling speciale */
				.chapter-title
				{
					font-weight: bold;
					text-align: center;
					display: block;
					width: 100%;
					margin: 0 auto;
				}

				/* Container per righe che contengono titoli di capitolo */
				.tei-line-chapter
				{
					display: block !important;
					width: 100%;
					text-align: center;
					margin: 10px 0;
				}

				/* Override per titoli di capitolo all'interno delle righe */
				.chapter-title
				{
					font-weight: bold;
				}

				/* Nomi di persona */
				.persName
				{
					color: #0056b3;
					font-weight: bold;
					cursor: help;
					position: relative;
				}

				/* Nomi di luogo */
				.placeName
				{
					color: #28a745;
					font-weight: bold;
					cursor: help;
					position: relative;
				}

				/* Titoli di opere */
				.title
				{
					color: #ffa500;
					font-weight: bold;
					cursor: help;
					position: relative;
				}

				/* Nomi di oggetto */
				.ident
				{
					color: #60a040;
					font-weight: bold;
					cursor: help;
					position: relative;
				}

				/* Nomi propri */
				.name
				{
					color: #ff00ff;
					font-weight: bold;
					cursor: help;
					position: relative;
				}

				/* Ruoli */
				.rolename
				{
					color: #ff69b4;
					font-weight: bold;
					cursor: help;
					position: relative;
				}

				/* Organizzazioni */
				.orgname
				{
					color: #663399;
					font-weight: bold;
					cursor: help;
					position: relative;
				}

				/* Date */
				.date
				{
					color: #0000ff;
					font-weight: bold;
					cursor: help;
					position: relative;
				}

				/* Nome di uno stato */
				.country
				{
					color: #20e040;
					font-weight: bold;
					cursor: help;
					position: relative;
				}

				/* Paragrafi TEI con spaziatura ottimizzata */
				.tei-paragraph
				{
					margin-bottom: 15px;
					line-height: 1.8;
					font-size: 16px;
				}

				/* Controllo degli a capo nei paragrafi */
				.tei-paragraph br
				{
					line-height: 0.8;
					margin: 0;
					padding: 0;
				}

				/* Righe di testo TEI con interattività */
				.tei-line
				{
					display: inline-block;
					margin: 0;
					padding: 2px;
					border-radius: 3px;
					transition: background-color 0.3s ease;
					line-height: 1.2;
				}

				/* Effetto hover per le righe cliccabili */
				.tei-line:hover
				{
					background-color: #f0f8ff;
				}

				/* Esclamazioni */
				.exclamation
				{
					color: #dc3545;
					font-weight: bold;
					cursor: help;
					position: relative;
				}

				/* Citazioni dirette */
				.quoted-text
				{
					font-style: italic;
					color: #303030;
					padding: 2px 4px;
					border-radius: 3px;
					cursor: help;
					position: relative;
				}

				/* Termini tecnici */
				.term
				{
					color: #c82333;
					font-weight: bold;
					cursor: help;
					position: relative;
				}

				/* Enfasi */
				.emph
				{
					font-weight: bold;
					color: #e05d00;
					cursor: help;
					position: relative;
				}

				/* Stile per gli elementi &lt;hi rend="bold"&gt; */
				.rend-bold
				{
					font-weight: bold;
				}

				/* Stile per gli elementi &lt;hi rend="italic"&gt; */
				.rend-italic
				{
					font-style: italic;
				}

				/* Stili per la visualizzazione dell'indentazione */
				.rend-indent
				{
					/* Rientro di 2 spazi */
					margin-left: 2em;
				}

				.rend-indent-2
				{
					/* Rientro di 4 spazi */
					margin-left: 4em;
				}

				/* Stile per l'allineamento a destra */
				.rend-align-right
				{
					text-align: right;
					display: block;
				}

				/* Stile per l'allineamento centrale */
				.rend-align-center
				{
					text-align: center;
					display: block;
				}

				/* Stile per centrare la riga e contemporaneamente creare un effetto di indentazione dal centro */
				.rend-center-indent
				{
					text-align: center;
					margin-left: 12em;
					display: block;
				}


				/* Stile generico per elementi evidenziati (zone cliccate) */
				.highlight
				{
					background-color: #ffe5b4 !important;
					border: 2px solid #ff6b35 !important;
					border-radius: 4px !important;
					padding: 2px 4px !important;
				}

				/* Stili per i tooltip personalizzati */
				[title]
				{
					position: relative;
					cursor: help;
				}

				[title]:hover::after
				{
					content: attr(title);
					position: absolute;
					bottom: 100%;
					left: 50%;
					transform: translateX(-50%);
					background: #333;
					color: white;
					padding: 6px 10px;
					border-radius: 4px;
					font-size: 0.85em;
					white-space: nowrap;
					z-index: 1000;
					box-shadow: 0 2px 6px rgba(0,0,0,0.2);
					margin-bottom: 5px;
					max-width: 250px;
					word-wrap: break-word;
					white-space: normal;
					text-align: center;
					line-height: 1.3;
				}

				[title]:hover::before
				{
					content: '';
					position: absolute;
					bottom: 100%;
					left: 50%;
					transform: translateX(-50%);
					border: 4px solid transparent;
					border-top-color: #333;
					z-index: 1000;
					margin-bottom: 1px;
				}

				/* Tooltip specifici per ogni tipo di elemento */
				.persName:hover::after
				{
					background: #0056b3;
				}

				.persName:hover::before
				{
					border-top-color: #0056b3;
				}

				.placeName:hover::after
				{
					background: #28a745;
				}

				.placeName:hover::before
				{
					border-top-color: #28a745;
				}

				.title:hover::after
				{
					background: #ffa500;
				}

				.title:hover::before
				{
					border-top-color: #ffa500;
				}

				.exclamation:hover::after
				{
					background: #dc3545;
				}

				.exclamation:hover::before
				{
					border-top-color: #dc3545;
				}

				.quoted-text:hover::after
				{
					background: #6f42c1;
				}

				.quoted-text:hover::before
				{
					border-top-color: #6f42c1;
				}

				.term:hover::after
				{
					background: #C82333;
				}

				.term:hover::before
				{
					border-top-color: #C82333;
				}

				.emph:hover::after
				{
					background: #e05d00;
				}

				.emph:hover::before
				{
					border-top-color: #e05d00;
				}

				.ident:hover::after
				{
					background: #60a040;
				}

				.ident:hover::before
				{
					border-top-color: #60a040;
				}

				.name:hover::after
				{
					background: #ff00ff;
				}

				.name:hover::before
				{
					border-top-color: #ff00ff;
				}

				.rolename:hover::after
				{
					background: #ff69b4;
				}

				.rolename:hover::before
				{
					border-top-color: #ff69b4;
				}

				.orgname:hover::after
				{
					background: #663399;
				}

				.orgname:hover::before
				{
					border-top-color: #663399;
				}

				.date:hover::after
				{
					background: #0000ff;
				}

				.date:hover::before
				{
					border-top-color: #0000ff;
				}

				.country:hover::after
				{
					background: #20e040;
				}

				.country:hover::before
				{
					border-top-color: #20e040;
				}

				/* Elementi individuali nella griglia di descrizione */
				.description-item
				{
					background: transparent;
					padding: 5px;
					border-radius: 0;
					border: none;
					box-shadow: none;
				}

				/* Pulsanti di controllo (Mostra zone, Nascondi fenomeni, ecc.) */
				.toggle-button
				{
					background: #007bff;
					color: white;
					border: none;
					padding: 10px 20px;
					border-radius: 5px;
					cursor: pointer;
					font-size: 14px;
					margin: 10px 0;
					transition: background-color 0.3s;
				}

				/* Effetto hover per i pulsanti */
				.toggle-button:hover
				{
					background: #0056b3;
				}

				/* Pulsante con margine sinistro */
				.toggle-button.margin-left
				{
					margin-left: 10px;
				}

				/* Aree cliccabili */
				area
				{
					cursor: pointer;
				}

				/* Classe per elementi nascosti */
				.hidden
				{
					display: none !important;
				}

				/* Titoli negli elementi di descrizione */
				.description-item h4
				{
					margin-top: 0;
					margin-bottom: 2px;
					font-size: 1.1em;
				}

				/* Paragrafi negli elementi di descrizione */
				.description-item p
				{
					margin: 0;
				}

				/* Non faccio mettere le virgolette automatiche */
				q
				{
					quotes: &quot;&quot; &quot;&quot;;
				}

				/* Disattiva gli eventi del mouse (incluso l'hover che mostra il tooltip) per tutti gli elementi che devono essere 'nascosti' (colore inherit). */
				.highlights-off
				{
					pointer-events: none !important;
				}
				</xsl:text></style>
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
				<script><xsl:text disable-output-escaping="yes">
			// ===================================================
			// SISTEMA DI VISUALIZZAZIONE TEI CON ZONE INTERATTIVE
			// ===================================================
			// Questo script gestisce l'interattività tra le immagini
			// del manoscritto e il testo codificato in TEI XML.
			// Permette di evidenziare dinamicamente le righe di testo
			// cliccando sulle zone corrispondenti nell'immagine.
			//
			// ARCHITETTURA:
			// - Sistema responsive che si adatta al ridimensionamento della finestra
			// - Supporto multi-pagina automatico per qualsiasi numero di pagine
			// - Due modalità di interazione: zone visibili (overlay rosso) e invisibili
			// - Sincronizzazione bidirezionale tra immagini e testo codificato
			// - Gestione accessibile con supporto per screen reader
			//
			// COMPONENTI PRINCIPALI:
			// 1. Inizializzazione e gestione eventi (resize, load)
			// 2. Creazione dinamica delle zone interattive
			// 3. Sistema di evidenziazione del testo
			// 4. Controlli interfaccia utente (toggle highlights, zone overlay)
			// 5. Sistema di scaling responsive per coordinate
			// 6. Gestione zone multi-pagina
			// 7. Aree invisibili per click quando overlay è nascosto

			// ===================================================
			// UTILITY FUNCTIONS
			// ===================================================

			/**
			 * Rileva se il dispositivo è iOS (iPhone, iPad, iPod)
			 * @returns {boolean} True se è un dispositivo iOS
			 */
			function isIOS()
			{
				return /iPad|iPhone|iPod/.test(navigator.userAgent) || (navigator.platform === 'MacIntel' &amp;&amp; navigator.maxTouchPoints > 1);
			}

			// ===================================================
			// INIZIALIZZAZIONE E GESTIONE EVENTI
			// ===================================================

			// Associa la funzione di inizializzazione all'evento di caricamento della pagina
			// Garantisce che il DOM sia completamente caricato prima dell'inizializzazione
			window.onload = FunOnLoad;

			// Listener per il ridimensionamento della finestra
			// Quando l'utente ridimensiona la finestra, le zone devono essere
			// ricreate con le nuove coordinate scalate per mantenere la precisione
			// Listener per il ridimensionamento della finestra
			// Quando l'utente ridimensiona la finestra, le zone devono essere
			// ricreate con le nuove coordinate scalate per mantenere la precisione
			window.addEventListener('resize', function()
			{
				// Ricrea tutte le zone con le nuove dimensioni
				// Timeout di 100ms per evitare chiamate multiple durante il resize continuo
				setTimeout(function()
				{
					createTestZonesDirectly();
					// Reimposta il pulsante alla modalità "Mostra zone"
					// per evitare confusione quando le zone vengono ricreate
					const zoneButton = document.querySelector('button[onclick*="ToggleZoneOverlay"]');
					if (zoneButton)
					{
						zoneButton.textContent = 'Mostra zone';
						zoneButton.style.background = '#007bff'; // Blu = zone nascoste
						ZoneEvidenziate = false; // Sincronizza variabile globale
					}
				}, 100);
			});

			// Funzione di inizializzazione principale chiamata al caricamento della pagina
			// Inizializza il sistema di zone interattive dopo che il DOM è completamente caricato
			function FunOnLoad()
			{
				// Piccolo delay di 50ms per assicurarsi che le immagini siano completamente caricate
				// e che le loro dimensioni naturali siano disponibili per il calcolo dello scaling
				setTimeout(createTestZonesDirectly, 50);
			}

			// Variabile globale per tracciare lo stato delle zone overlay
			// true = zone visibili (overlay rosso attivo)
			// false = zone nascoste (aree invisibili attive)
			let ZoneEvidenziate = false;

			// ===================================================
			// CREAZIONE DINAMICA DELLE ZONE INTERATTIVE
			// ===================================================

			/**
			 * Crea dinamicamente tutte le zone interattive per tutte le pagine
			 * Questa funzione è chiamata al caricamento e al ridimensionamento
			 * Supporta automaticamente qualsiasi numero di pagine
			 *
			 * FUNZIONALITÀ:
			 * - Trova dinamicamente tutti i page-wrapper presenti nel DOM
			 * - Rimuove overlay esistenti per evitare duplicati
			 * - Crea nuovi overlay per ogni pagina con zone scalate
			 * - Genera sia zone visibili che aree invisibili per click
			 * - Ottimizza l'altezza del container principale
			 */
			function createTestZonesDirectly()
			{
				// Trova tutti i page-wrapper dinamicamente
				// Questo permette di supportare qualsiasi numero di pagine senza modifiche al codice
				const pageWrappers = document.querySelectorAll('.page-wrapper');

				// Itera su ogni page-wrapper per creare le zone interattive
				pageWrappers.forEach((pageWrapper, index) =>
				{
					// Converte indice 0-based in numero pagina 1-based
					const pageNumber = index + 1;

					// Rimuovi overlay esistenti per evitare duplicati durante ricreazione
					const existingOverlay = document.getElementById(`zone-overlay-page${pageNumber}`);
					if (existingOverlay)
					{
						existingOverlay.remove();
					}

					// Rimuovi aree invisibili esistenti per evitare duplicati durante ricreazione
					const existingInvisible = document.getElementById(`invisible-click-areas-page${pageNumber}`);
					if (existingInvisible)
					{
						existingInvisible.remove();
					}

					// Crea nuovo overlay per questa pagina
					let overlay = document.createElement('div');
					overlay.id = `zone-overlay-page${pageNumber}`;
					// CSS inline per posizionamento assoluto e gestione z-index
					// pointer-events: none inizialmente (sarà gestito dal toggle)
					overlay.style.cssText = 'position: absolute; top: 0; left: 0; pointer-events: none; z-index: 10; display: none;';
					createFallbackZonesForPage(overlay, pageNumber);
					pageWrapper.appendChild(overlay);
				});

				// Ottimizza l'altezza del container principale per utilizzare tutto lo spazio disponibile
				adjustMainContainerHeight();
			}

			// ===================================================
			// EVIDENZIAZIONE DEL TESTO
			// ===================================================

			/**
			 * Evidenzia la riga di testo corrispondente alla zona cliccata
			 * @param {string} zoneId - ID della zona cliccata (es. "ZN_P1_R1")
			 *
			 * FUNZIONALITÀ:
			 * - Rimuove evidenziazione precedente per garantire single selection
			 * - Trova la riga corrispondente tramite ID sincronizzato
			 * - Applica classe CSS 'highlight' per styling
			 * - Scroll automatico per centrare la riga evidenziata
			 * - Sincronizzazione bidirezionale immagine ↔ testo
			 */
			function highlightText(zoneId)
			{
				// Rimuovi evidenziazione da tutti gli elementi precedenti
				// Garantisce che solo una riga sia evidenziata alla volta
				const allElements = document.querySelectorAll('.highlight');
				allElements.forEach(el => el.classList.remove('highlight'));

				// L'ID della zona corrisponde esattamente all'ID della riga nel DOM
				// Gli ID sono sincronizzati tra XML (zone) e HTML (line) dall'XSL
				const lineId = zoneId;

				// Evidenzia la riga corrispondente nel testo
				const selectedLine = document.getElementById(lineId);
				if (selectedLine)
				{
					selectedLine.classList.add('highlight');
					// Scroll automatico con animazione smooth per centrare la riga evidenziata
					selectedLine.scrollIntoView({ behavior: 'smooth', block: 'center' });
					LastSelectedLine = selectedLine; // Per problema su IOS
				}
			}

			// ===================================================
			// CONTROLLI INTERFACCIA UTENTE
			// ===================================================

			/**
			 * Mostra/nasconde l'evidenziazione dei fenomeni notevoli nel testo
			 * I fenomeni notevoli includono: nomi di persona, luoghi, titoli, esclamazioni, ecc.
			 * @param {HTMLElement} Pulsante - Il pulsante che ha scatenato l'evento
			 *
			 * FUNZIONALITÀ:
			 * - Toggle tra stato "visibile" e "nascosto" per elementi semantici TEI
			 * - Gestisce 10 tipi di elementi: persName, placeName, exclamation, quoted-text, term, emph, ident, .name, .rolename, .orgname, country, title, date
			 * - Quando nascosti: applica stile 'inherit' e classe 'highlights-off'
			 * - Quando visibili: rimuove stili inline per permettere al CSS di riprendere controllo
			 * - Feedback visivo: colore pulsante (rosso=nascosto, blu=visibile)
			 * - Disabilita pointer-events quando nascosti per evitare tooltip indesiderati
			 */
			function ToggleHighlights(Pulsante)
			{
				// Rimuovi evidenziazione da tutti gli elementi (zone cliccate)
				const allElements = document.querySelectorAll('.highlight');
				allElements.forEach(el => el.classList.remove('highlight'));

				// Seleziona tutti i fenomeni notevoli nel testo (elementi semantici TEI)
				const highlights = document.querySelectorAll('.persName, .placeName, .exclamation, .quoted-text, .term, .emph, .ident, .name, .rolename, .orgname, .country, .title, .date');

				if(Pulsante.textContent === 'Nascondi fenomeni notevoli')
				{
					// Nasconde i colori degli elementi evidenziati
					// Ripristina lo stile normale del testo
					highlights.forEach(el =>
					{
						el.style.color = 'inherit';
						el.style.fontWeight = 'normal';
						el.style.borderBottom = 'none';
						el.style.backgroundColor = 'inherit';
						el.classList.add('highlights-off');
					});
					Pulsante.textContent = 'Mostra fenomeni notevoli';
					Pulsante.style.background = '#dc3545'; // Rosso = nascosto
				}
				else
				{
					// Ripristina i colori originali degli elementi evidenziati
					// Riattiva gli stili CSS definiti nel foglio di stile
					highlights.forEach(el =>
					{
						el.classList.remove('highlights-off');
						el.style.color = '';
						el.style.fontWeight = '';
						el.style.borderBottom = '';
						el.style.backgroundColor = '';
					});
					Pulsante.textContent = 'Nascondi fenomeni notevoli';
					Pulsante.style.background = '#007bff'; // Blu = visibile
				}
			}

			/**
			 * Mostra/nasconde le zone rosse di overlay sulle immagini
			 * Quando le zone sono nascoste, rimangono attive le aree invisibili per i click
			 * @param {HTMLElement} Pulsante - Il pulsante che ha scatenato l'evento
			 *
			 * FUNZIONALITÀ:
			 * - Toggle tra due modalità di interazione: zone visibili e invisibili
			 * - Modalità visibile: overlay rosso con bordi e sfondo semi-trasparente
			 * - Modalità invisibile: aree trasparenti che mantengono l'interattività
			 * - Supporto multi-pagina: applica modifiche a tutte le pagine dinamicamente
			 * - Sincronizza variabile globale ZoneEvidenziate per stato consistente
			 * - Feedback visivo: colore pulsante (rosso=nascosto, blu=visibile)
			 * - Mantiene evidenziazione del testo anche quando zone sono nascoste
			 */
			function ToggleZoneOverlay(Pulsante)
			{
				// Trova tutti i page-wrapper dinamicamente per supportare più pagine
				const pageWrappers = document.querySelectorAll('.page-wrapper');

				// Rimuovi evidenziazione da tutti gli elementi (zone cliccate)
				const allElements = document.querySelectorAll('.highlight');
				allElements.forEach(el => el.classList.remove('highlight'));

				if(Pulsante.textContent === 'Mostra zone')
				{
					// MODALITÀ: Mostra le zone rosse
					Pulsante.textContent = 'Nascondi zone';
					Pulsante.style.background = '#dc3545'; // Rosso = zone visibili

					// Mostra le zone e disattiva le aree invisibili per tutte le pagine
					pageWrappers.forEach((pageWrapper, index) =>
					{
						const pageNumber = index + 1;
						const overlay = document.getElementById(`zone-overlay-page${pageNumber}`);
						const invisibleAreas = document.getElementById(`invisible-click-areas-page${pageNumber}`);

						if (overlay)
						{
							overlay.style.display = 'block';
						}
						if (invisibleAreas)
						{
							invisibleAreas.style.pointerEvents = 'none';
							invisibleAreas.style.display = 'none';
						}
					});
					ZoneEvidenziate = true;
				}
				else
				{
					// MODALITÀ: Nascondi le zone rosse
					Pulsante.textContent = 'Mostra zone';
					Pulsante.style.background = '#007bff'; // Blu = zone nascoste

					// Nascondi le zone overlay e attiva le aree invisibili per tutte le pagine
					pageWrappers.forEach((pageWrapper, index) =>
					{
						const pageNumber = index + 1;
						const overlay = document.getElementById(`zone-overlay-page${pageNumber}`);
						const invisibleAreas = document.getElementById(`invisible-click-areas-page${pageNumber}`);

						if (overlay)
						{
							overlay.style.display = 'none';
						}
						if (invisibleAreas)
						{
							invisibleAreas.style.pointerEvents = 'auto';
							invisibleAreas.style.display = 'block';
						}
					});
					ZoneEvidenziate = false;
				}
			}

			// ===================================================
			// SISTEMA DI SCALING RESPONSIVE
			// ===================================================

			/**
			 * Crea le zone visibili (overlay rosso) per una pagina specifica
			 * Le coordinate vengono scalate in base alle dimensioni dell'immagine visualizzata
			 * @param {HTMLElement} overlay - Container dove aggiungere le zone
			 * @param {number} pageNumber - Numero della pagina (1, 2, 3, ecc.)
			 *
			 * FUNZIONALITÀ:
			 * - Genera zone dinamicamente per la pagina specifica
			 * - Calcola fattore di scala basato su dimensioni naturali vs visualizzate
			 * - Crea elementi div con posizionamento assoluto e styling inline
			 * - Aggiunge gestori di eventi per click e hover
			 * - Inserisce etichette con ID zona per debug
			 * - Crea anche aree invisibili per modalità nascosta
			 */
			function createFallbackZonesForPage(overlay, pageNumber)
			{
				// Genera zone dinamicamente per la pagina specifica
				const zones = generateDynamicZonesForPage(pageNumber);

				// Ottieni l'immagine per questa pagina
				const image = document.getElementById(`page${pageNumber}-image`);
				if (!image)
				{
					return;
				}

				// Calcola il fattore di scala per adattare le coordinate
				// alle dimensioni attuali dell'immagine visualizzata
				const scaleFactor = calculateScaleFactor(image);

				zones.forEach(zone =>
				{
					// Scala le coordinate originali in base al fattore di scala
					const scaledCoords = scaleZoneCoordinates(zone, scaleFactor);

					// Crea elemento div per la zona visibile
					const zoneDiv = document.createElement('div');
					zoneDiv.style.cssText = `position: absolute; left: ${scaledCoords.ulx}px; top: ${scaledCoords.uly}px; width: ${scaledCoords.width}px; height: ${scaledCoords.height}px; border: 1px solid red; background: rgba(255, 0, 0, 0.1); cursor: pointer; pointer-events: auto;`;

					// Aggiungi gestore click per evidenziare il testo
					zoneDiv.onclick = function()
					{
						highlightText(zone.id);
					};

					// Effetti hover per feedback visivo
					zoneDiv.onmouseover = () => zoneDiv.style.background = 'rgba(255, 0, 0, 0.3)';
					zoneDiv.onmouseout = () => zoneDiv.style.background = 'rgba(255, 0, 0, 0.1)';

						// Aggiungi etichetta con ID della zona fissata all'angolo in alto a sinistra della zona
						const label = document.createElement('span');
						label.style.cssText = 'position: absolute; top: 0; left: 0; background: red; color: white; padding: 2px 5px; font-size: 9px; line-height: 1; white-space: nowrap; pointer-events: none; z-index: 1;';
						label.textContent = zone.id;
						zoneDiv.appendChild(label);

					overlay.appendChild(zoneDiv);
				});

				// Crea anche aree invisibili per i click quando l'overlay è nascosto
				createInvisibleClickAreasForPage(zones, pageNumber, scaleFactor);
			}

			/**
			 * Calcola il fattore di scala tra le dimensioni naturali e quelle visualizzate
			 * Questo permette di adattare le coordinate delle zone quando l'immagine viene ridimensionata
			 * @param {HTMLImageElement} image - L'elemento immagine da analizzare
			 * @returns {number} Fattore di scala (es. 0.5 se l'immagine è ridotta al 50%)
			 *
			 * LOGICA:
			 * - naturalWidth/Height: dimensioni originali dell'immagine
			 * - offsetWidth/Height: dimensioni attualmente visualizzate nel browser
			 * - Math.min(): usa il fattore più piccolo per mantenere proporzioni
			 * - Evita distorsioni quando l'immagine viene scalata
			 */
			function calculateScaleFactor(image)
			{
				// Ottieni le dimensioni naturali (originali) dell'immagine
				const naturalWidth = image.naturalWidth;
				const naturalHeight = image.naturalHeight;

				// Ottieni le dimensioni attuali visualizzate nel browser
				const displayWidth = image.offsetWidth;
				const displayHeight = image.offsetHeight;

				// Calcola il fattore di scala per entrambe le dimensioni
				const scaleX = displayWidth / naturalWidth;
				const scaleY = displayHeight / naturalHeight;

				// Usa il fattore più piccolo per mantenere le proporzioni
				// Questo evita distorsioni quando l'immagine viene scalata
				return(Math.min(scaleX, scaleY));
			}

			/**
			 * Applica il fattore di scala alle coordinate originali della zona
			 * @param {Object} zone - Oggetto zona con coordinate originali
			 * @param {number} scaleFactor - Fattore di scala da applicare
			 * @returns {Object} Coordinate scalate per la visualizzazione attuale
			 *
			 * COORDINATE:
			 * - ulx, uly: angolo superiore sinistro
			 * - lrx, lry: angolo inferiore destro
			 * - width, height: dimensioni calcolate dalle coordinate
			 */
			function scaleZoneCoordinates(zone, scaleFactor)
			{
				return({
					ulx: zone.ulx * scaleFactor,    // X coordinate superiore sinistra
					uly: zone.uly * scaleFactor,    // Y coordinate superiore sinistra
					lrx: zone.lrx * scaleFactor,    // X coordinate inferiore destra
					lry: zone.lry * scaleFactor,    // Y coordinate inferiore destra
					width: (zone.lrx - zone.ulx) * scaleFactor, // Larghezza scalata
					height: (zone.lry - zone.uly) * scaleFactor // Altezza scalata
				});
			}

			// ===================================================
			// GESTIONE ZONE DINAMICHE MULTI-PAGINA
			// ===================================================

			/**
			 * Genera le zone per una pagina specifica filtrando dall'array globale
			 * @param {number} pageNumber - Numero della pagina (1, 2, 3, ecc.)
			 * @returns {Array} Array di zone per la pagina specificata
			 *
			 * LOGICA:
			 * - Usa pattern matching per filtrare zone per pagina specifica
			 * - Pattern: ZN_P{numero}_ per identificazione pagine
			 * - Converte formato da array coords a oggetti con proprietà nominate
			 * - Supporta automaticamente qualsiasi numero di pagine
			 */
			function generateDynamicZonesForPage(pageNumber)
			{
				// Filtra le zone per la pagina specifica usando un pattern dinamico
				// Esempio: pagina 1 = "ZN_P1_", pagina 2 = "ZN_P2_", ecc.
				const pagePrefix = `ZN_P${pageNumber}_`;
				const pageZones = zonesData.filter(zone => zone.id.startsWith(pagePrefix));

				// Converte le zone nel formato richiesto con coordinate separate
				const zones = pageZones.map(zone => ({
					id: zone.id,
					ulx: zone.coords[0],    // X superiore sinistra
					uly: zone.coords[1],    // Y superiore sinistra
					lrx: zone.coords[2],    // X inferiore destra
					lry: zone.coords[3]     // Y inferiore destra
				}));

				return(zones);
			}

			/**
			 * Genera tutte le zone da tutte le pagine (funzione legacy)
			 * Mantenuta per compatibilità ma non più utilizzata
			 * @returns {Array} Array di tutte le zone
			 */
			function generateDynamicZones()
			{
				// Le zone sono già generate dall'XSL nell'array zonesData
				// Converti l'array zonesData nel formato richiesto
				const zones = zonesData.map(zone => ({
					id: zone.id,
					ulx: zone.coords[0],
					uly: zone.coords[1],
					lrx: zone.coords[2],
					lry: zone.coords[3]
				}));

				return(zones);
			}

			/**
			 * Funzione legacy non più utilizzata
			 * @deprecated Le zone sono ora generate dinamicamente
			 * @returns {Array} Array vuoto
			 */
			function createFallbackZonesStatic()
			{
				// Questa funzione non dovrebbe più essere chiamata
				// perché generateDynamicZones() ora restituisce sempre zone
				return([]);
			}

			// ===================================================
			// AREE INVISIBILI PER CLICK
			// ===================================================

			/**
			 * Crea aree invisibili per i click quando le zone rosse sono nascoste
			 * Queste aree mantengono l'interattività anche quando l'overlay è disabilitato
			 * @param {Array} zones - Array di zone per la pagina
			 * @param {number} pageNumber - Numero della pagina
			 * @param {number} scaleFactor - Fattore di scala per le coordinate
			 *
			 * FUNZIONALITÀ:
			 * - Crea container per aree invisibili se non esiste
			 * - Genera aree trasparenti con stesse coordinate delle zone visibili
			 * - Mantiene gestori di eventi per click e evidenziazione testo
			 * - Background e border trasparenti per invisibilità
			 * - Aggiunge attributi data per identificazione e debug
			 */
			function createInvisibleClickAreasForPage(zones, pageNumber, scaleFactor)
			{
				// Trova il page-wrapper per questa pagina
				const pageWrappers = document.querySelectorAll('.page-wrapper');
				const pageWrapper = pageWrappers[pageNumber - 1]; // pageNumber è 1-based, array è 0-based

				if (!pageWrapper)
				{
					return;
				}

				// Crea un contenitore per le aree invisibili
				let invisibleContainer = document.getElementById(`invisible-click-areas-page${pageNumber}`);
				if (!invisibleContainer)
				{
					invisibleContainer = document.createElement('div');
					invisibleContainer.id = `invisible-click-areas-page${pageNumber}`;
					invisibleContainer.style.cssText = 'position: absolute; top: 0; left: 0; pointer-events: auto; z-index: 5;';
					pageWrapper.appendChild(invisibleContainer);
				}

				zones.forEach(zone =>
				{
					// Scala le coordinate per le aree invisibili
					const scaledCoords = scaleZoneCoordinates(zone, scaleFactor);

					// Crea area invisibile per il click
					const clickArea = document.createElement('div');
					clickArea.style.cssText = `position: absolute; left: ${scaledCoords.ulx}px; top: ${scaledCoords.uly}px; width: ${scaledCoords.width}px; height: ${scaledCoords.height}px; cursor: pointer; pointer-events: auto; background: transparent; border: 1px solid transparent;`;

					// Gestore click per evidenziare il testo
					clickArea.onclick = function(e)
					{
						e.preventDefault();
						e.stopPropagation();
						highlightText(zone.id);
					};

					// Attributi per identificazione e debug
					clickArea.setAttribute('data-zone-id', zone.id);
					clickArea.setAttribute('data-zone-name', zone.id);
					invisibleContainer.appendChild(clickArea);
				});
			}

			// Per problema di resize su IOS
			let LastSelectedLine = null;

			/**
			 * Aggiusta l'altezza del main-container per ottimizzare l'uso dello spazio verticale
			 *
			 * FUNZIONALITÀ:
			 * - Calcola altezza disponibile sottraendo sezioni fisse dall'altezza finestra
			 * - Include margini e padding nel calcolo per precisione
			 * - Gestisce valori NaN nei calcoli di stile
			 * - Imposta altezza solo se superiore a 100px (valore minimo)
			 * - Layout responsive che si adatta alle dimensioni schermo
			 */
			function adjustMainContainerHeight()
			{
				const descriptionSection = document.querySelector('.description-section');
				const mainContainer = document.getElementById('main-container');
				const body = document.body;

				if (descriptionSection &amp;&amp; mainContainer)
				{
					// Calcola l'altezza della description-section includendo margini
					const descStyle = window.getComputedStyle(descriptionSection);
					const marginTop = parseInt(descStyle.marginTop);
					const marginBottom = parseInt(descStyle.marginBottom);
					const descHeight = descriptionSection.offsetHeight + (isNaN(marginTop) ? 0 : marginTop) + (isNaN(marginBottom) ? 0 : marginBottom);

					// Calcola l'altezza del body padding
					const bodyStyle = window.getComputedStyle(body);
					const paddingTop = parseInt(bodyStyle.paddingTop);
					const paddingBottom = parseInt(bodyStyle.paddingBottom);
					const bodyPadding = (isNaN(paddingTop) ? 0 : paddingTop) + (isNaN(paddingBottom) ? 0 : paddingBottom);

					// Calcola l'altezza disponibile per il main-container
					const availableHeight = window.innerHeight - descHeight - bodyPadding;

					// Imposta l'altezza calcolata solo se è un valore valido
					if (availableHeight > 100)
					{
						mainContainer.style.height = availableHeight + 'px';
					}

					// Su iOS/iPad, fa uno scroll automatico per assicurarsi che il contenuto sia visibile per risolvere un problema di calcolo della dimensione dello schermo
					if (isIOS())
					{
						setTimeout
						(
							function()
							{
								if(LastSelectedLine != null)
								{
									LastSelectedLine.scrollIntoView({ behavior: 'smooth', block: 'center' });
								}
								else
								{
									// Scroll per mostrare il primo elemento del text-container
									const textContainer = document.getElementById('text-container');
									if (textContainer &amp;&amp; textContainer.firstElementChild)
									{
										textContainer.firstElementChild.scrollIntoView({ behavior: 'smooth', block: 'start' });
									}
								}
							},
							10
						);
					}
				}
			}
			</xsl:text></script>
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
