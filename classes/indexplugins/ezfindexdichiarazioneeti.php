<?php

class ezfIndexDichiarazioneeti implements ezfIndexPlugin
{
    public function modify( eZContentObject $contentObject, &$docList )
    {
    	
    	if ( $contentObject->attribute( 'class_identifier' ) == 'dichiarazione_impresa' )
        {

            $version = $contentObject->currentVersion();
            $data_map = $contentObject->dataMap();
            
			//------------- Attributi in sede_azienda --------------------------------------------------------
					
			$tipologieSede = $data_map['elenco_sedi_azienda']->content();
            $tipologieSedeArray = $tipologieSede['relation_list'];
            
            foreach ($tipologieSedeArray as $sede){

                $sedeEZCO = eZContentObject::fetchByRemoteID($sede['contentobject_remote_id']);
                $data_map_sede = $sedeEZCO->dataMap();

                $this->addToDocList( $version, $docList, 'tipo_sede____s',  $data_map_sede['tipo']->content() );
                $this->addToDocList( $version, $docList, 'comune_sede____s',  $data_map_sede['comune']->content() );
                $this->addToDocList( $version, $docList, 'provincia_sede____s',  $data_map_sede['provincia']->content() );
                
            }

			//------------- Attributi in categoria_generale --------------------------------------------------------

            $categorieGenerali = $data_map['elenco_categorie_generali']->content();
            $generaliArray = $categorieGenerali['relation_list'];
            
            foreach ($generaliArray as $categoriaGenerale){

            	$categoriaGeneraleEZCO = eZContentObject::fetchByRemoteID($categoriaGenerale['contentobject_remote_id']);

                $data_map_generale = $categoriaGeneraleEZCO->dataMap();

                $this->addToDocList( $version, $docList, 'categoria_generale____s',  $data_map_generale['categoria']->content() );
                $this->addToDocList( $version, $docList, 'categoria_generale_classifica____s',  $data_map_generale['classifica']->content() );
            }

			//------------- Attributi in categoria_specializzate --------------------------------------------------------

            $categorieSpecializzate = $data_map['elenco_categorie_specializzate']->content();
            $specializzateArray = $categorieSpecializzate['relation_list'];
            
            foreach ($specializzateArray as $categoriaSpecializzata){
            
            	$categoriaSpecializzataEZCO = eZContentObject::fetchByRemoteID($categoriaSpecializzata['contentobject_remote_id']);
            
            	$data_map_specializzata = $categoriaSpecializzataEZCO->dataMap();
            
            	$this->addToDocList( $version, $docList, 'categoria_specializzata____s',  $data_map_specializzata['categoria']->content() );
                $this->addToDocList( $version, $docList, 'categoria_specializzata_classifica____s',  $data_map_specializzata['classifica']->content() );
            }
                        
            //------------- Attributi in sezione_attivita --------------------------------------------------------
            
            $attivita = $data_map['elenco_sezione_attivita']->content();
            $attivitaArray = $attivita['relation_list'];
            
            foreach ($attivitaArray as $elementAttivita){
            
            	$attivitaEZCO = eZContentObject::fetchByRemoteID($elementAttivita['contentobject_remote_id']);
            
            	$data_map_attivita = $attivitaEZCO->dataMap();
            
            	$this->addToDocList( $version, $docList, 'attivita____s',  $data_map_attivita['attivita']->content() );
            }
            
			//------------- Attributi in ente_iscrizione --------------------------------------------------------

            $enti = $data_map['elenco_ente_iscrizione']->content();
            $enteArray = $enti['relation_list'];
            
            foreach ($enteArray as $ente){
            
            	$enteEZCO = eZContentObject::fetchByRemoteID($ente['contentobject_remote_id']);
            
            	$data_map_ente = $enteEZCO->dataMap();
            
            	$this->addToDocList( $version, $docList, 'ente____s',  $data_map_ente['ente']->content() );
            }
           
           
           //------------- Attributi in numero dipendenti --------------------------------------------------------
           
           $dipendenti = $data_map['elenco_numero_dipendenti']->content();
           $dipendentiArray = $dipendenti['relation_list'];
           
           foreach ($dipendentiArray as $dipendentiElement){
           
           	$dipendentiEZCO = eZContentObject::fetchByRemoteID($dipendentiElement['contentobject_remote_id']);
           
           	$data_map_dipendenti = $dipendentiEZCO->dataMap();
           
           	$this->addToDocList( $version, $docList, 'dipendenti_tipologia____s',  $data_map_dipendenti['tipologia']->content() );
           	$this->addToDocList( $version, $docList, 'dipendenti_determinati____s',  $data_map_dipendenti['tempo_determinato']->content() );
           	$this->addToDocList( $version, $docList, 'dipendenti_indeterminati____s',  $data_map_dipendenti['tempo_indeterminato']->content() );
           }
            
        }
    }

    protected function addToDocList( eZContentObjectVersion $version, &$docList, $key, $value )
    {        
        $key = 'extra_' . $key;
        if( $version instanceof eZContentObjectVersion )
        {                
            $availableLanguages = $version->translationList( false, false );                
            foreach ( $availableLanguages as $languageCode ) 
            {
                if ( $docList[$languageCode] instanceof eZSolrDoc )
                {
                    $docList[$languageCode]->addField( $key, $value );
                }                
            }
        }
    }
}