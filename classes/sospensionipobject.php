<?php

class SospensioniPObject extends eZPersistentObject
{
    const STATUS_ACCEPTED = 1;
    const STATUS_PENDING = 0;
    /**
     * Construct, use {@link UserExpObject::create()} to create new objects.
     *
     * @param array $row
     */
    protected function __construct(  $row )
    {
        parent::eZPersistentObject( $row );
    }

    public static function definition()
    {
        static $def = array( 'fields' => array(

            'piva_azienda' => array(
                'name' => 'piva_azienda',
                'datatype' => 'string',
                'default' => '',
                'required' => true ),
            'id_ente' => array(
                'name' => 'id_ente',
                'datatype' => 'integer',
                'default' => '',
                'required' => true ),
            'sospensione' => array(
                'name' => 'sospensione',
                'datatype' => 'integer',
                'default' => 0,
                'required' => true )
        ),
                         'keys' => array('piva_azienda', 'id_ente'),
                         'class_name' => 'SospensioniPObject',
                         'name' => 'sospensione_azienda_ente' );
        return $def;
    }

    public static function create( array $row = array() )
    {

        $object = new self( $row );
        return $object;
    }

    /**
     * Shows the data as JACExtensionData with given id
     * @param int $stato object state
     * @param bool $asObject
     * @return JACExtensionData
     */
    public static function fetchByAziendaEnte( $pivaazienda , $idente , $asObject = true)
    {
        $result = eZPersistentObject::fetchObjectList(
                                    self::definition(),
                                        null,
                                        array( 'piva_azienda' => $pivaazienda,
											   'id_ente' => $idente),
                                        $asObject,
                                        null,
                                        null );

        return $result;

    }

}


?>

