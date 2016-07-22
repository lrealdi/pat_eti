<?php


/**
 * Classe per l'operatore di template DistanzaGeo
 *  calcolo distanza tra due coordinate
 * @author
 */
class DistanzaGeo{
    public $Operators;
    
    /** 
     * Nome dell'operatore
     * 
     * @param string $name
     */
    public function __construct( $name = 'distanzageo' ){
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
        return array( 'distanzageo' => array( 'lat1' => array( 'type' => 'float',
                                                               'required' => true,
                                                               'default' => '' ),
                                            'long1' =>  array( 'type' => 'float',
                                                               'required' => true,
                                                               'default' => '' ),
        									  'lat2' => array( 'type' => 'float',
                                                               'required' => true,
                                                               'default' => '' ),
                                            'long2' =>  array( 'type' => 'float',
                                                               'required' => true,
                                                               'default' => '' )) 
            
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
        
        $latitude1 = $namedParameters['lat1'];
        $longitude1 = $namedParameters['long1'];
        $latitude2 = $namedParameters['lat2'];
        $longitude2 = $namedParameters['long2'];
		
		if (is_numeric($latitude1)&&is_numeric($longitude1)&&is_numeric($latitude2)&&is_numeric($longitude2)) {
			$theta = $longitude1 - $longitude2;
			$miles = (sin(deg2rad($latitude1)) * sin(deg2rad($latitude2))) + (cos(deg2rad($latitude1)) * cos(deg2rad($latitude2)) * cos(deg2rad($theta)));
			$miles = acos($miles);
			$miles = rad2deg($miles);
			$miles = $miles * 60 * 1.1515;
			$feet = $miles * 5280;
			$yards = $feet / 3;
			$kilometers = $miles * 1.609344;
			$meters = $kilometers * 1000;
		}
		else {
			$miles = 0;
			$feet = 0;
			$yards = 0;
			$kilometers = 0;
			$meters = 0;
			
		}
		$operatorValue = compact('miles','feet','yards','kilometers','meters');
   }
    
}

