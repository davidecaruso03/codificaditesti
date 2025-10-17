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
	return /iPad|iPhone|iPod/.test(navigator.userAgent) || (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1);
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

	if (descriptionSection && mainContainer)
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
						if (textContainer && textContainer.firstElementChild)
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
