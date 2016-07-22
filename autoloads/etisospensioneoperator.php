<?php


/**
 * Classe per l'operatore di template
 * 
 * @author 
 */
class ETISospensioneOperator{
    public $Operators;
    
    /** 
     * Nome dell'operatore
     * 
     * @param string $name
     */
    public function __construct( $name = 'etisospensione' ){
        $this->Operators = array( $name );
    }
    
    /**
     * Elenco degli operatori
     * 
     * @return array
     */
    function operatorList(){
        return $this->Operators;
    }
    
    /**
     * Vero se la lista dei parametri esiste per operatore
     * 
     * @return boolean
     */
    public function namedParameterPerOperator(){
        return true;
    }
    
    /**
     * Parametri da assegnare agli operatori
     * 
     * @return type
     */
    public function namedParameterList(){
        return array( 'etisospensione' => array( 'result_type' => array( 'type' => 'string',
                                                                         'required' => true,
                                                                         'default' => 'statosospensioneenteazienda' ),
                                                    'piva_azienda' =>  array( 'type' => 'string',
                                                                  'required' => true,
                                                                  'default' => '' ),
        											'id_ente' =>  array( 'type' => 'int',
                                                                  'required' => true,
                                                                  'default' => '' ),
        											'sospensione' =>  array( 'type' => 'int',
                                                                  'required' => false,
                                                                  'default' => '1' )) 
            
                      );
    }

    /**
     * Switch sui possibili operatori
     * 
     * @param type $tpl
     * @param type $operatorName
     * @param type $operatorParameters
     * @param type $rootNamespace
     * @param type $currentNamespace
     * @param type $operatorValue
     * @param type $namedParameters
     */
    public function modify( $tpl, $operatorName, $operatorParameters,  $rootNamespace, $currentNamespace, &$operatorValue, $namedParameters  ){
        
        $result_type = $namedParameters['result_type'];
        
        $pivaazienda = $namedParameters['piva_azienda'];
        $idente = $namedParameters['id_ente'];
        $sospensione = $namedParameters['sospensione'];
        
        if( $result_type == 'statosospensioneenteazienda' ){

			$operatorValue = SospensioniPObject::fetchByAziendaEnte( $pivaazienda , $idente );
        }
        else if( $result_type == 'impostasospensioneenteazienda' ){
        	$newrecfields = array( 'piva_azienda' => $pivaazienda, 'id_ente' => $idente, 'sospensione' => $sospensione);
        	$simpleObj = SospensioniPObject::create( $newrecfields );
        	$simpleObj->store();
        	$operatorValue = $simpleObj->attribute( 'status' );
 
        }
        else if( $result_type == 'annnullasospensioneenteazienda' ){
        	$cond = array( 'piva_azienda' => $pivaazienda, 'id_ente' => $idente);
        	eZPersistentObject::removeObject( SospensioniPObject::definition(), $cond );
 
        }
    }
    
}

