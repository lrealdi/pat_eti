<?php

    
    //$listaETI = $_POST['listaETI'];
    
    foreach ( $_GET as $name => $value )
    {
        if ($name == 'listaETI')
            $listaETI = $value;
    } 
        
    $arrayETI = explode(",", $listaETI);
    $arrayETI = array_filter($arrayETI);
   
    $objects = eZContentObject::fetchIDArray( $arrayETI , true ); 

    $list = isset( $Params['List'] ) ? $Params['List'] : 'ETIlist';
    $returnData = array();

    //li scorro uno ad uno
    foreach($objects as $child){
       
        //print_r($child);
        //echo('#######################################');
        $data_map_child = $child->dataMap();
        
        //print_r($data_map_child['cognome_legale_rappresentante']->content());
	

		// flag impresa aderente al consorzio (1) o impresa uguale a consorzio (2)
		$consorzio_aderente_consorzio_valore = $data_map_child['consorzio_aderente_consorzio_valore']->content();
		$impresaaderenteconsorzio = 'NO';
		$impresaugualeconsorzio = 'NO';
		
		if ( $consorzio_aderente_consorzio_valore == 1) {
			$impresaaderenteconsorzio = 'SI';
		} elseif ($consorzio_aderente_consorzio_valore == 2) {
			$impresaugualeconsorzio = 'SI';
		}
        
		// fetch sedi (sede legale, sede operativa/amministrativa, sede stabilimento)
		// data_map.elenco_sedi_azienda.content.relation_list
		$sediazienda = $data_map_child['elenco_sedi_azienda']->content();
		$arraysediazienda = $sediazienda['relation_list'];
		
		$indsedelegale = "";
		$comusedelegale = "";
		$provsedelegale = "";
		$capsedelegale = "";
		$indsedeamm = "";
		$comusedeamm = "";
		$provsedeamm = "";
		$capsedeamm = "";
		$indstabilimento = "";
		$comustabilimento = "";
		$provstabilimento = "";
		$capstabilimento = "";

		
		foreach ($arraysediazienda as $itemsede) {
			//$arraysede = array();
			$sedeazienda = eZContentObject::fetchByRemoteID($itemsede['contentobject_remote_id']);
			$data_map_sedeazienda = $sedeazienda->dataMap();
			
			$tiposede = $data_map_sedeazienda['tipo']->content();
			$indirizzosede = $data_map_sedeazienda['indirizzo']->content();
			$comunesede = $data_map_sedeazienda['comune']->content();
			$provinciasede = $data_map_sedeazienda['provincia']->content();
			$capsede = $data_map_sedeazienda['cap']->content();
			if($tiposede == "Sede legale") {
				$indsedelegale = $indirizzosede;
				$comusedelegale = $comunesede;
				$provsedelegale = $provinciasede;
				$capsedelegale = $capsede;		
			} elseif ($tiposede == "Sede amministrativa") {
				$indsedeamm = $indirizzosede;
				$comusedeamm = $comunesede;
				$provsedeamm = $provinciasede;
				$capsedeamm = $capsede;
			}elseif ($tiposede == "Stabilimento") {
				$indstabilimento = $indirizzosede;
				$comustabilimento = $comunesede;
				$provstabilimento = $provinciasede;
				$capstabilimento = $capsede;
			}
			
			//$arraysede += array("Indirizzo ".$tiposede => $indirizzosede);
			//$arraysede += array("Comune ".$tiposede => $comunesede);
			//$arraysede += array("Provincia ".$tiposede => $provinciasede);
		}


		// fetch sede legale consorzio
		// data_map.elenco_sedi_consorzio.content.relation_list
		$sediconsorzio = $data_map_child['elenco_sedi_consorzio']->content();
		$arraysediconsorzio = $sediconsorzio['relation_list'];

		$indconsorzio = "";
		$comuconsorzio = "";
		$provconsorzio = "";
		$capconsorzio = "";

		foreach ($arraysediconsorzio as $itemsede) {
			$sedeconsorzio = eZContentObject::fetchByRemoteID($itemsede['contentobject_remote_id']);
			$data_map_sedeconsorzio = $sedeconsorzio->dataMap();
			
			$tiposede = $data_map_sedeconsorzio['tipo']->content();
			$indirizzosede = $data_map_sedeconsorzio['indirizzo']->content();
			$comunesede = $data_map_sedeconsorzio['comune']->content();
			$provinciasede = $data_map_sedeconsorzio['provincia']->content();
			$capsede = $data_map_sedeconsorzio['cap']->content();
			if($tiposede == "Sede consorzio") {
				$indconsorzio = $indirizzosede;
				$comuconsorzio = $comunesede;
				$provconsorzio = $provinciasede;
				$capconsorzio = $capsede;		
			} 		
		}

		
		// fetch dipendenti (Dirigenti, Dirigenti tecnici, Quadri tecnici, Quadri amministrativi, Impiegatoi tecnici, Impiegati amministrativi, Operai) a tempo determinato e indeterminato
		// data_map.elenco_numero_dipendenti.content.relation_list
		$dipendenti = $data_map_child['elenco_numero_dipendenti']->content();
		$arraydipendenti = $dipendenti['relation_list'];

		$dirigentitempodet = "";
		$dirigentitempoindet = "";
		$dirigentitecntempodet = "";
		$dirigentitecntempoindet = "";
		$quadritecntempodet = "";
		$quadritecntempoindet = "";
		$quadriammtempodet = "";
		$quadriammtempoindet = "";
		$imptecntempodet = "";
		$imptecntempoindet = "";
		$impammtempodet = "";
		$impammtempoindet = "";
		$operaitempodet = "";
		$operaitempoindet = "";
		
		foreach ($arraydipendenti as $itemdipendente) {
			$dipendentisingolatipologia = eZContentObject::fetchByRemoteID($itemdipendente['contentobject_remote_id']);
			$data_map_dipendenti = $dipendentisingolatipologia->dataMap();
			
			$tipologiadip = $data_map_dipendenti['tipologia']->content();
			$tempodetdip = $data_map_dipendenti['tempo_determinato']->content();
			$tempoindetdip = $data_map_dipendenti['tempo_indeterminato']->content();
			if($tipologiadip == "Dirigenti") {
				$dirigentitempodet = $tempodetdip;
				$dirigentitempoindet = $tempoindetdip;
			} elseif ($tipologiadip == "Dirigenti tecnici") {
				$dirigentitecntempodet = $tempodetdip;
				$dirigentitecntempoindet = $tempoindetdip;
			} elseif ($tipologiadip == "Quadri tecnici") {
				$quadritecntempodet = $tempodetdip;
				$quadritecntempoindet = $tempoindetdip;
			} elseif ($tipologiadip == "Quadri amministrativi") {
				$quadritecntempodet = $tempodetdip;
				$quadritecntempoindet = $tempoindetdip;
			} elseif ($tipologiadip == "Impiegati tecnici") {
				$imptecntempodet = $tempodetdip;
				$imptecntempoindet = $tempoindetdip;
			} elseif ($tipologiadip == "Impiegati amministrativi") {
				$impammtempodet = $tempodetdip;
				$impammtempoindet = $tempoindetdip;
//			} elseif ($tipologiadip == "Operai") {
			} elseif ($tipologiadip == "Maestranze (totale soci lavoratori e/o operai)") {
				$operaitempodet = $tempodetdip;
				$operaitempoindet = $tempoindetdip;
			}
		
		}
		
		
		
		// fetch categorie generali (OG) con classifica
		// data_map.elenco_categorie_generali.content.relation_list
		$elencoOG = $data_map_child['elenco_categorie_generali']->content();
		$arrayOG = $elencoOG['relation_list'];

		foreach ($arrayOG as $itemOG) {
			$singoloOG = eZContentObject::fetchByRemoteID($itemOG['contentobject_remote_id']);
			$data_map_singoloOG = $singoloOG->dataMap();
			
			$classificaOG01 = "";
			$classificaOG02 = "";
			$classificaOG03 = "";
			$classificaOG04 = "";
			$classificaOG05 = "";
			$classificaOG06 = "";
			$classificaOG07 = "";
			$classificaOG08 = "";
			$classificaOG09 = "";
			$classificaOG10 = "";
			$classificaOG11 = "";
			$classificaOG12 = "";
			$classificaOG13 = "";
			
			$categoria = $data_map_singoloOG['categoria']->content();
			$classifica = $data_map_singoloOG['classifica']->content();
			if($categoria == "OG 1") {
				$classificaOG01 = $classifica;
			} elseif ($categoria == "OG 2") {
				$classificaOG02 = $classifica;		
			} elseif ($categoria == "OG 3") {
				$classificaOG03 = $classifica;
			} elseif ($categoria == "OG 4") {
				$classificaOG04 = $classifica;
			} elseif ($categoria == "OG 5") {
				$classificaOG05 = $classifica;
			} elseif ($categoria == "OG 6") {
				$classificaOG06 = $classifica;
			} elseif ($categoria == "OG 7") {
				$classificaOG07 = $classifica;
			} elseif ($categoria == "OG 8") {
				$classificaOG08 = $classifica;
			} elseif ($categoria == "OG 9") {
				$classificaOG09 = $classifica;
			} elseif ($categoria == "OG 10") {
				$classificaOG10 = $classifica;
			} elseif ($categoria == "OG 11") {
				$classificaOG11 = $classifica;
			} elseif ($categoria == "OG 12") {
				$classificaOG12 = $classifica;
			} elseif ($categoria == "OG 13") {
				$classificaOG13 = $classifica;
			}		
		}

		
		// fetch categorie speciali (OS) con classifica
		// data_map.elenco_categorie_specializzate.content.relation_list
		$elencoOS = $data_map_child['elenco_categorie_specializzate']->content();
		$arrayOS = $elencoOS['relation_list'];

		foreach ($arrayOS as $itemOS) {
			$singoloOS = eZContentObject::fetchByRemoteID($itemOS['contentobject_remote_id']);
			$data_map_singoloOS = $singoloOS->dataMap();
			
			$classificaOS01 = "";
			$classificaOS02 = "";
			$classificaOS02A = "";
			$classificaOS02A = "";
			$classificaOS03 = "";
			$classificaOS04 = "";
			$classificaOS05 = "";
			$classificaOS06 = "";
			$classificaOS07 = "";
			$classificaOS08 = "";
			$classificaOS09 = "";
			$classificaOS10 = "";
			$classificaOS11 = "";
			$classificaOS12 = "";
			$classificaOS12A = "";
			$classificaOS12B = "";
			$classificaOS13 = "";
			$classificaOS14 = "";
			$classificaOS15 = "";
			$classificaOS16 = "";
			$classificaOS17 = "";
			$classificaOS18 = "";
			$classificaOS18A = "";
			$classificaOS18B = "";
			$classificaOS19 = "";
			$classificaOS20 = "";
			$classificaOS20A = "";
			$classificaOS20B = "";
			$classificaOS21 = "";
			$classificaOS22 = "";
			$classificaOS23 = "";
			$classificaOS24 = "";
			$classificaOS25 = "";
			$classificaOS26 = "";
			$classificaOS27 = "";
			$classificaOS28 = "";
			$classificaOS29 = "";
			$classificaOS30 = "";
			$classificaOS31 = "";
			$classificaOS32 = "";
			$classificaOS33 = "";
			$classificaOS34 = "";
			$classificaOS35 = "";
			
			$categoria = $data_map_singoloOS['categoria']->content();
			$classifica = $data_map_singoloOS['classifica']->content();
			if($categoria == "OS 1") {
				$classificaOS01 = $classifica;
			} elseif ($categoria == "OS 2") {
				$classificaOS02 = $classifica;
			} elseif ($categoria == "OS 2-A") {
				$classificaOS02A = $classifica;
			} elseif ($categoria == "OS 2-B") {
				$classificaOS02B = $classifica;
			} elseif ($categoria == "OS 3") {
				$classificaOS03 = $classifica;
			} elseif ($categoria == "OS 4") {
				$classificaOS04 = $classifica;
			} elseif ($categoria == "OS 5") {
				$classificaOS05 = $classifica;
			} elseif ($categoria == "OS 6") {
				$classificaOS06 = $classifica;
			} elseif ($categoria == "OS 7") {
				$classificaOS07 = $classifica;
			} elseif ($categoria == "OS 8") {
				$classificaOS08 = $classifica;
			} elseif ($categoria == "OS 9") {
				$classificaOS09 = $classifica;
			} elseif ($categoria == "OS 10") {
				$classificaOS10 = $classifica;
			} elseif ($categoria == "OS 11") {
				$classificaOS11 = $classifica;
			} elseif ($categoria == "OS 12") {
				$classificaOS12 = $classifica;
			} elseif ($categoria == "OS 12-A") {
				$classificaOS12A = $classifica;
			} elseif ($categoria == "OS 12-B") {
				$classificaOS12B = $classifica;
			} elseif ($categoria == "OS 13") {
				$classificaOS13 = $classifica;
			} elseif ($categoria == "OS 14") {
				$classificaOS14 = $classifica;
			} elseif ($categoria == "OS 15") {
				$classificaOS15 = $classifica;
			} elseif ($categoria == "OS 16") {
				$classificaOS16 = $classifica;
			} elseif ($categoria == "OS 17") {
				$classificaOS17 = $classifica;
			} elseif ($categoria == "OS 18") {
				$classificaOS18 = $classifica;
			} elseif ($categoria == "OS 18-A") {
				$classificaOS18A = $classifica;
			} elseif ($categoria == "OS 18-B") {
				$classificaOS18B = $classifica;
			} elseif ($categoria == "OS 19") {
				$classificaOS19 = $classifica;
			} elseif ($categoria == "OS 20") {
				$classificaOS20 = $classifica;
			} elseif ($categoria == "OS 20-A") {
				$classificaOS20A = $classifica;
			} elseif ($categoria == "OS 20-B") {
				$classificaOS20B = $classifica;
			} elseif ($categoria == "OS 21") {
				$classificaOS21 = $classifica;
			} elseif ($categoria == "OS 22") {
				$classificaOS22 = $classifica;
			} elseif ($categoria == "OS 23") {
				$classificaOS23 = $classifica;
			} elseif ($categoria == "OS 24") {
				$classificaOS24 = $classifica;
			} elseif ($categoria == "OS 25") {
				$classificaOS25 = $classifica;
			} elseif ($categoria == "OS 26") {
				$classificaOS26 = $classifica;
			} elseif ($categoria == "OS 27") {
				$classificaOS27 = $classifica;
			} elseif ($categoria == "OS 28") {
				$classificaOS28 = $classifica;
			} elseif ($categoria == "OS 29") {
				$classificaOS29 = $classifica;
			} elseif ($categoria == "OS 30") {
				$classificaOS30 = $classifica;
			} elseif ($categoria == "OS 31") {
				$classificaOS31 = $classifica;
			} elseif ($categoria == "OS 32") {
				$classificaOS32 = $classifica;
			} elseif ($categoria == "OS 33") {
				$classificaOS33 = $classifica;
			} elseif ($categoria == "OS 34") {
				$classificaOS34 = $classifica;
			} elseif ($categoria == "OS 35") {
				$classificaOS35 = $classifica;
			}		
		}
		
		// fetch attività
		// data_map.elenco_sezione_attivita.content.relation_list
		$elencoattivita = $data_map_child['elenco_sezione_attivita']->content();
		$arrayattivita = $elencoattivita['relation_list'];

		$valoriattivita = array();
		foreach ($arrayattivita as $itemattivita) {
			$attivita = eZContentObject::fetchByRemoteID($itemattivita['contentobject_remote_id']);
			$data_map_attivita = $attivita->dataMap();
			
			$valoriattivita[] = $data_map_attivita['attivita']->content();
		}
		$elencoattivita = implode(" | ", $valoriattivita);
		
		
		// costruzione tracciato record csv
		
        $returnData[] = array(
		"Nome" => $data_map_child['nome_legale_rappresentante']->content(),
		"Cognome" => $data_map_child['cognome_legale_rappresentante']->content(),
		"Codice Fiscale" => $data_map_child['codicefiscale_legale_rappresentante']->content(),
		"Impresa" => $data_map_child['ragione_sociale_azienda']->content(),
		"Partita IVA" => $data_map_child['partita_iva_azienda']->content(),

		"Indirizzo sede legale" => $indsedelegale,
		"Comune sede legale" => $comusedelegale,
		"Provincia sede legale" => $provsedelegale,
		"CAP sede legale" => $capsedelegale,

		"Indirizzo sede operativa/amministrativa (se diversa da quella legale)" => $indsedeamm,
		"Comune sede operativa" => $comusedeamm,
		"Provincia sede operativa" => $provsedeamm,
		"CAP sede operativa" => $capsedeamm,

		"Indirizzo dello stabilimento" => $indstabilimento,
		"Comune stabilimento" => $comustabilimento,
		"Provincia stabilimento" => $provstabilimento,
		"CAP stabilimento" => $capstabilimento,
		
		"Telefono" => $data_map_child['telefono']->content(),
		"Fax" => $data_map_child['fax']->content(),
		"Email certificata (PEC)" => $data_map_child['emailpec']->content(),
		"Email non-PEC" => $data_map_child['email']->content(),
		"Impresa aderente al consorzio" => $impresaaderenteconsorzio,
		"Nome consorzio" => $data_map_child['ragione_sociale_consorzio']->content(),
		"P.IVA consorzio" => $data_map_child['partita_iva_consorzio']->content(),

		"Indirizzo sede legale consorzio" => $indconsorzio,
		"Comune consorzio" => $comuconsorzio,
		"Provincia consorzio" => $provconsorzio,
		"CAP consorzio" => $capconsorzio,
		
		"L'impresa risulta essere un consorzio" => $impresaugualeconsorzio,
		
		"Dirigenti a tempo determinato " => $dirigentitempodet,
		"Dirigenti a tempo indeterminato " => $dirigentitempoindet,
		"Dirigenti tecnici a tempo determinato " => $dirigentitecntempodet,
		"Dirigenti tecnici a tempo indeterminato " => $dirigentitecntempoindet,
		"Quadri tecnici a tempo determinato " => $quadritecntempodet,
		"Quadri tecnici a tempo indeterminato " => $quadritecntempoindet,
		"Quadri amministrativi a tempo determinato " => $quadriammtempodet,
		"Quadri amministrativi a tempo indeterminato " => $quadriammtempoindet,
		"Impiegati tecnici a tempo determinato " => $imptecntempodet,
		"Impiegati tecnici a tempo indeterminato " => $imptecntempoindet,
		"Impiegati amministrativi a tempo determinato " => $impammtempodet,
		"Impiegati amministrativi a tempo indeterminato " => $impammtempoindet,
		"Maestranze (totale soci lavoratori e/o operai) a tempo determinato " => $operaitempodet,
		"Maestranze (totale soci lavoratori e/o operai) a tempo indeterminato " => $operaitempoindet,

//		"Numero soci lavoratori" => $data_map_child['numero_soci_lavoratori']->content(),
		"Possesso requisiti art. 38 del D.lgs 163/2006" => $data_map_child['req_ordine_gen_art38dlgs163_2006_descrizione']->content(),

		"Classifica OG 1" => $classificaOG01,
		"Classifica OG 2" => $classificaOG02,
		"Classifica OG 3" => $classificaOG03,
		"Classifica OG 4" => $classificaOG04,
		"Classifica OG 5" => $classificaOG05,
		"Classifica OG 6" => $classificaOG06,
		"Classifica OG 7" => $classificaOG07,
		"Classifica OG 8" => $classificaOG08,
		"Classifica OG 9" => $classificaOG09,
		"Classifica OG 10" => $classificaOG10,
		"Classifica OG 11" => $classificaOG11,
		"Classifica OG 12" => $classificaOG12,
		"Classifica OG 13" => $classificaOG13,
		"Classifica OS 1" => $classificaOS01,
		"Classifica OS 2" => $classificaOS02,
		"Classifica OS 2-A" => $classificaOS02A,
		"Classifica OS 2-B" => $classificaOS02A,
		"Classifica OS 3" => $classificaOS03,
		"Classifica OS 4" => $classificaOS04,
		"Classifica OS 5" => $classificaOS05,
		"Classifica OS 6" => $classificaOS06,
		"Classifica OS 7" => $classificaOS07,
		"Classifica OS 8" => $classificaOS08,
		"Classifica OS 9" => $classificaOS09,
		"Classifica OS 10" => $classificaOS10,
		"Classifica OS 11" => $classificaOS11,
		"Classifica OS 12" => $classificaOS12,
		"Classifica OS 12-A" => $classificaOS12A,
		"Classifica OS 12-B" => $classificaOS12B,
		"Classifica OS 13" => $classificaOS13,
		"Classifica OS 14" => $classificaOS14,
		"Classifica OS 15" => $classificaOS15,
		"Classifica OS 16" => $classificaOS16,
		"Classifica OS 17" => $classificaOS17,
		"Classifica OS 18" => $classificaOS18,
		"Classifica OS 18-A" => $classificaOS18A,
		"Classifica OS 18-B" => $classificaOS18B,
		"Classifica OS 19" => $classificaOS19,
		"Classifica OS 20" => $classificaOS20,
		"Classifica OS 20-A" => $classificaOS20A,
		"Classifica OS 20-B" => $classificaOS20B,
		"Classifica OS 21" => $classificaOS21,
		"Classifica OS 22" => $classificaOS22,
		"Classifica OS 23" => $classificaOS23,
		"Classifica OS 24" => $classificaOS24,
		"Classifica OS 25" => $classificaOS25,
		"Classifica OS 26" => $classificaOS26,
		"Classifica OS 27" => $classificaOS27,
		"Classifica OS 28" => $classificaOS28,
		"Classifica OS 29" => $classificaOS29,
		"Classifica OS 30" => $classificaOS30,
		"Classifica OS 31" => $classificaOS31,
		"Classifica OS 32" => $classificaOS32,
		"Classifica OS 33" => $classificaOS33,
		"Classifica OS 34" => $classificaOS34,
		"Classifica OS 35" => $classificaOS35,
		"Attività" => $elencoattivita

        );
        
		/*
		foreach ($lencoOG as $categoriaOG => $classificaOG) {
			$returnData[] += array($categoriaOG => $classificaOG);
		}
		*/
		
    }

    $cacheDirectory = eZSys::cacheDirectory() . '/csv_export';
    $cacheFile = $list . '.csv';
    eZFile::create( $cacheFile, $cacheDirectory, '' );

    $cacheFilePath = eZSys::rootDir() . '/' . $cacheDirectory . '/' . $cacheFile;
    //print_r($cacheFilePath);
    //die();
    if ( file_exists( $cacheFilePath ) )
    {
        $headers = array_keys( $returnData[0] );
        $fp = fopen( $cacheFilePath, 'w' );
        fputcsv( $fp, $headers );
        foreach( $returnData as $returnDataItem )
        {
            fputcsv( $fp, array_values( $returnDataItem ) );
        }
        fclose($fp);
        eZFile::download( $cacheFilePath , true , $cacheFile);
    }
