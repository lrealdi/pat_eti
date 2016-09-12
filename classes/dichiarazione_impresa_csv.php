<?php

use Opencontent\Opendata\Api\EnvironmentLoader;
use Opencontent\Opendata\Api\ContentSearch;
use Opencontent\Opendata\Api\ContentRepository;


class PatEtiDichiarazioneImpresaCsv
{
    protected $fileName = array();

    protected $results = array();

    protected static $objects = array();

    protected static $sediPerImpresa = array();

    protected static $sediConsorzioPerImpresa = array();

    protected static $dipendentiPerImpresa = array();

    protected static $categoriePerImpresa = array();

    protected static $categorieSpecializzatePerImpresa = array();

    protected $contentSearch;

    protected $contentRepository;

    public function __construct($query, $fileName = 'ETIlist.csv')
    {
        $this->fileName = $fileName;

        if (strpos('limit', $query) === false) {
            $query .= ' limit 100';
        }
        $nextPageQuery = urldecode($query);
        while ($nextPageQuery) {
            $data = (array)self::getContentSearch()->search($nextPageQuery);
            $this->results = array_merge($this->results, $data['searchHits']);
            $nextPageQuery = $data['nextPageQuery'];
        }
    }

    /**
     * @return ContentRepository
     * @throws \Opencontent\Opendata\Api\Exception\EnvironmentForbiddenException
     * @throws \Opencontent\Opendata\Api\Exception\EnvironmentMisconfigurationException
     * @throws \Opencontent\Opendata\Api\Exception\OutOfRangeException
     */
    protected static function getContentRepository()
    {
        $currentEnvironment = EnvironmentLoader::loadPreset('content');
        $parser = new ezpRestHttpRequestParser();
        $request = $parser->createRequest();
        $currentEnvironment->__set('request', $request);

        $contentRepository = new ContentRepository();
        $contentRepository->setEnvironment($currentEnvironment);

        return $contentRepository;
    }

    /**
     * @return ContentSearch
     * @throws \Opencontent\Opendata\Api\Exception\EnvironmentForbiddenException
     * @throws \Opencontent\Opendata\Api\Exception\EnvironmentMisconfigurationException
     * @throws \Opencontent\Opendata\Api\Exception\OutOfRangeException
     */
    protected static function getContentSearch()
    {
        $currentEnvironment = EnvironmentLoader::loadPreset('content');
        $parser = new ezpRestHttpRequestParser();
        $request = $parser->createRequest();
        $currentEnvironment->__set('request', $request);

        $contentSearch = new ContentSearch();
        $contentSearch->setEnvironment($currentEnvironment);

        return $contentSearch;
    }

    public function download($CSVDelimiter = ',', $CSVEnclosure = '"')
    {
        ob_get_clean(); //chiudo l'ob_start dell'index.php

        header('X-Powered-By: eZ Publish');
        header('Content-Description: File Transfer');
        header('Content-Type: text/csv; charset=utf-8');
        header("Content-Disposition: attachment; filename=$this->fileName");
        header("Pragma: no-cache");
        header("Expires: 0");
        $output = fopen('php://output', 'w');

        $headers = array_keys($this->getConverters());
        fputcsv($output, $headers, $CSVDelimiter, $CSVEnclosure);

        foreach ($this->results as $item) {
            $values = $this->buildRow($item);
            fputcsv($output, $values, $CSVDelimiter, $CSVEnclosure);
            flush();
        }
        eZExecution::cleanExit();
    }

    protected function buildRow(array $item)
    {
        $data = array();
        $contentData = $item['data']['ita-IT'];
        $converter = $this->getConverters();
        foreach ($converter as $header => $callback) {
            $data[$header] = $callback($contentData, $item);
        }

        return $data;
    }

    protected static function getSedi($data, $item)
    {
        if (!isset( self::$sediPerImpresa[$item['metadata']['id']] )) {
            self::$sediPerImpresa[$item['metadata']['id']] = array(
                "Sede legale" => array(),
                "Sede amministrativa" => array(),
                "Stabilimento" => array(),
            );
            foreach ($data['elenco_sedi_azienda'] as $sede) {
                $sedeContent = self::getObject($sede['id']);
                if ($sedeContent !== null) {
                    $tipo = $sedeContent['data']['ita-IT']['tipo'];
                    self::$sediPerImpresa[$item['metadata']['id']][$tipo][] = $sedeContent['data']['ita-IT'];
                }
            }
        }

        return self::$sediPerImpresa[$item['metadata']['id']];
    }

    protected static function getSediConsorzio($data, $item)
    {
        if (!isset( self::$sediConsorzioPerImpresa[$item['metadata']['id']] )) {
            self::$sediConsorzioPerImpresa[$item['metadata']['id']] = array(
                "Sede consorzio" => array(),
            );
            foreach ($data['elenco_sedi_consorzio'] as $sede) {
                $sedeContent = self::getObject($sede['id']);
                if ($sedeContent !== null) {
                    $tipo = $sedeContent['data']['ita-IT']['tipo'];
                    self::$sediConsorzioPerImpresa[$item['metadata']['id']][$tipo][] = $sedeContent['data']['ita-IT'];
                }
            }
        }

        return self::$sediConsorzioPerImpresa[$item['metadata']['id']];
    }

    protected static function getDipendentiPerImpresa($data, $item)
    {
        if (!isset( self::$dipendentiPerImpresa[$item['metadata']['id']] )) {
            self::$dipendentiPerImpresa[$item['metadata']['id']] = array(
                "Dirigenti" => array(),
                "Dirigenti tecnici" => array(),
                "Quadri tecnici" => array(),
                "Quadri amministrativi" => array(),
                "Impiegati tecnici" => array(),
                "Impiegati amministrativi" => array(),
                "Maestranze (totale soci lavoratori e/o operai)" => array(),
            );
            foreach ($data['elenco_numero_dipendenti'] as $dipendente) {
                $dipendenteContent = self::getObject($dipendente['id']);
                if ($dipendenteContent !== null) {
                    $tipo = $dipendenteContent['data']['ita-IT']['tipologia'];
                    self::$dipendentiPerImpresa[$item['metadata']['id']][$tipo][] = $dipendenteContent['data']['ita-IT'];
                }
            }
        }

        return self::$dipendentiPerImpresa[$item['metadata']['id']];
    }

    protected static function getCategoriePerImpresa($data, $item)
    {
        if (!isset( self::$categoriePerImpresa[$item['metadata']['id']] )) {
            self::$categoriePerImpresa[$item['metadata']['id']] = array();
            foreach ($data['elenco_categorie_generali'] as $categoria) {
                $categoriaContent = self::getObject($categoria['id']);
                if ($categoriaContent !== null) {
                    self::$categoriePerImpresa[$item['metadata']['id']][] = $categoriaContent['data']['ita-IT'];
                }
            }
        }

        return self::$categoriePerImpresa[$item['metadata']['id']];
    }

    protected static function getCategorieSpecializzatePerImpresa($data, $item)
    {
        if (!isset( self::$categorieSpecializzatePerImpresa[$item['metadata']['id']] )) {
            self::$categorieSpecializzatePerImpresa[$item['metadata']['id']] = array();
            foreach ($data['elenco_categorie_specializzate'] as $categoria) {
                $categoriaContent = self::getObject($categoria['id']);
                if ($categoriaContent !== null) {
                    self::$categorieSpecializzatePerImpresa[$item['metadata']['id']][] = $categoriaContent['data']['ita-IT'];
                }
            }
        }

        return self::$categorieSpecializzatePerImpresa[$item['metadata']['id']];
    }

    protected static function getObject($id)
    {
        if (!isset( self::$objects[$id] )) {
            try {
                self::$objects[$id] = self::getContentRepository()->read($id);
            } catch (Exception $e) {
                eZDebug::writeError($e->getMessage(), __METHOD__);
                self::$objects[$id] = null;
            }
        }

        return self::$objects[$id];
    }

    protected function getConverters()
    {
        return array(
            "Nome" => function ($data, $item) {
                return $data['nome_legale_rappresentante'];
            },
            "Cognome" => function ($data, $item) {
                return $data['cognome_legale_rappresentante'];
            },
            "Codice Fiscale" => function ($data, $item) {
                return $data['codicefiscale_legale_rappresentante'];
            },
            "Impresa" => function ($data, $item) {
                return $data['ragione_sociale_azienda'];
            },
            "Partita IVA" => function ($data, $item) {
                return $data['partita_iva_azienda'];
            },

            "Indirizzo sede legale" => function ($data, $item) {
                $sedi = self::getSedi($data, $item);
                $result = array();
                foreach ($sedi['Sede legale'] as $sede) {
                    $result[] = $sede['indirizzo'];
                    break;
                }

                return implode("\n", array_unique($result));
            },
            "Comune sede legale" => function ($data, $item) {
                $sedi = self::getSedi($data, $item);
                $result = array();
                foreach ($sedi['Sede legale'] as $sede) {
                    $result[] = $sede['comune'];
                    break;
                }

                return implode("\n", array_unique($result));
            },
            "Provincia sede legale" => function ($data, $item) {
                $sedi = self::getSedi($data, $item);
                $result = array();
                foreach ($sedi['Sede legale'] as $sede) {
                    $result[] = $sede['provincia'];
                    break;
                }

                return implode("\n", array_unique($result));
            },
            "CAP sede legale" => function ($data, $item) {
                $sedi = self::getSedi($data, $item);
                $result = array();
                foreach ($sedi['Sede legale'] as $sede) {
                    $result[] = $sede['cap'];
                    break;
                }

                return implode("\n", array_unique($result));
            },

            "Indirizzo sede operativa/amministrativa (se diversa da quella legale)" => function ($data, $item) {
                $sedi = self::getSedi($data, $item);
                $result = array();
                foreach ($sedi['Sede amministrativa'] as $sede) {
                    $result[] = $sede['indirizzo'];
                    break;
                }

                return implode("\n", array_unique($result));
            },
            "Comune sede operativa" => function ($data, $item) {
                $sedi = self::getSedi($data, $item);
                $result = array();
                foreach ($sedi['Sede amministrativa'] as $sede) {
                    $result[] = $sede['comune'];
                    break;
                }

                return implode("\n", array_unique($result));
            },
            "Provincia sede operativa" => function ($data, $item) {
                $sedi = self::getSedi($data, $item);
                $result = array();
                foreach ($sedi['Sede amministrativa'] as $sede) {
                    $result[] = $sede['provincia'];
                    break;
                }

                return implode("\n", array_unique($result));
            },
            "CAP sede operativa" => function ($data, $item) {
                $sedi = self::getSedi($data, $item);
                $result = array();
                foreach ($sedi['Sede amministrativa'] as $sede) {
                    $result[] = $sede['cap'];
                    break;
                }

                return implode("\n", array_unique($result));
            },

            "Indirizzo dello stabilimento" => function ($data, $item) {
                $sedi = self::getSedi($data, $item);
                $result = array();
                foreach ($sedi['Stabilimento'] as $sede) {
                    $result[] = $sede['indirizzo'];
                    break;
                }

                return implode("\n", array_unique($result));
            },
            "Comune stabilimento" => function ($data, $item) {
                $sedi = self::getSedi($data, $item);
                $result = array();
                foreach ($sedi['Stabilimento'] as $sede) {
                    $result[] = $sede['comune'];
                    break;
                }

                return implode("\n", array_unique($result));
            },
            "Provincia stabilimento" => function ($data, $item) {
                $sedi = self::getSedi($data, $item);
                $result = array();
                foreach ($sedi['Stabilimento'] as $sede) {
                    $result[] = $sede['provincia'];
                    break;
                }

                return implode("\n", array_unique($result));
            },
            "CAP stabilimento" => function ($data, $item) {
                $sedi = self::getSedi($data, $item);
                $result = array();
                foreach ($sedi['Stabilimento'] as $sede) {
                    $result[] = $sede['cap'];
                    break;
                }

                return implode("\n", array_unique($result));
            },

            "Telefono" => function ($data, $item) {
                return $data['telefono'];
            },
            "Fax" => function ($data, $item) {
                return $data['fax'];
            },
            "Email certificata (PEC)" => function ($data, $item) {
                return $data['emailpec'];
            },
            "Email non-PEC" => function ($data, $item) {
                return $data['email'];
            },

            "Impresa aderente al consorzio" => function ($data, $item) {
                return $data['consorzio_aderente_consorzio_valore'] == 1 ? 'SI' : 'NO';
            },
            "Nome consorzio" => function ($data, $item) {
                return $data['ragione_sociale_consorzio'];
            },
            "P.IVA consorzio" => function ($data, $item) {
                return $data['partita_iva_consorzio'];
            },

            "Indirizzo sede legale consorzio" => function ($data, $item) {
                $sedi = self::getSediConsorzio($data, $item);
                $result = array();
                foreach ($sedi['Sede consorzio'] as $sede) {
                    $result[] = $sede['indirizzo'];
                    break;
                }

                return implode("\n", array_unique($result));
            },
            "Comune consorzio" => function ($data, $item) {
                $sedi = self::getSediConsorzio($data, $item);
                $result = array();
                foreach ($sedi['Sede consorzio'] as $sede) {
                    $result[] = $sede['comune'];
                    break;
                }

                return implode("\n", array_unique($result));
            },
            "Provincia consorzio" => function ($data, $item) {
                $sedi = self::getSediConsorzio($data, $item);
                $result = array();
                foreach ($sedi['Sede consorzio'] as $sede) {
                    $result[] = $sede['provincia'];
                    break;
                }

                return implode("\n", array_unique($result));
            },
            "CAP consorzio" => function ($data, $item) {
                $sedi = self::getSediConsorzio($data, $item);
                $result = array();
                foreach ($sedi['Sede consorzio'] as $sede) {
                    $result[] = $sede['cap'];
                    break;
                }

                return implode("\n", array_unique($result));
            },
            "L'impresa risulta essere un consorzio" => function ($data, $item) {
                return $data['consorzio_aderente_consorzio_valore'] == 2 ? 'SI' : 'NO';
            },

            "Dirigenti a tempo determinato " => function ($data, $item) {
                $dipendenti = self::getDipendentiPerImpresa($data, $item);
                $result = 0;
                foreach ($dipendenti['Dirigenti'] as $dipendente) {
                    $result += $dipendente['tempo_determinato'];
                }

                return $result;
            },
            "Dirigenti a tempo indeterminato" => function ($data, $item) {
                $dipendenti = self::getDipendentiPerImpresa($data, $item);
                $result = 0;
                foreach ($dipendenti['Dirigenti'] as $dipendente) {
                    $result += $dipendente['tempo_indeterminato'];
                }

                return $result;
            },
            "Dirigenti tecnici a tempo determinato" => function ($data, $item) {
                $dipendenti = self::getDipendentiPerImpresa($data, $item);
                $result = 0;
                foreach ($dipendenti['Dirigenti tecnici'] as $dipendente) {
                    $result += $dipendente['tempo_determinato'];
                }

                return $result;
            },
            "Dirigenti tecnici a tempo indeterminato " => function ($data, $item) {
                $dipendenti = self::getDipendentiPerImpresa($data, $item);
                $result = 0;
                foreach ($dipendenti['Dirigenti tecnici'] as $dipendente) {
                    $result += $dipendente['tempo_indeterminato'];
                }

                return $result;
            },
            "Quadri tecnici a tempo determinato " => function ($data, $item) {
                $dipendenti = self::getDipendentiPerImpresa($data, $item);
                $result = 0;
                foreach ($dipendenti['Quadri tecnici'] as $dipendente) {
                    $result += $dipendente['tempo_determinato'];
                }

                return $result;
            },
            "Quadri tecnici a tempo indeterminato " => function ($data, $item) {
                $dipendenti = self::getDipendentiPerImpresa($data, $item);
                $result = 0;
                foreach ($dipendenti['Quadri tecnici'] as $dipendente) {
                    $result += $dipendente['tempo_indeterminato'];
                }

                return $result;
            },
            "Quadri amministrativi a tempo determinato " => function ($data, $item) {
                $dipendenti = self::getDipendentiPerImpresa($data, $item);
                $result = 0;
                foreach ($dipendenti['Quadri amministrativi'] as $dipendente) {
                    $result += $dipendente['tempo_determinato'];
                }

                return $result;
            },
            "Quadri amministrativi a tempo indeterminato " => function ($data, $item) {
                $dipendenti = self::getDipendentiPerImpresa($data, $item);
                $result = 0;
                foreach ($dipendenti['Quadri amministrativi'] as $dipendente) {
                    $result += $dipendente['tempo_indeterminato'];
                }

                return $result;
            },
            "Impiegati tecnici a tempo determinato " => function ($data, $item) {
                $dipendenti = self::getDipendentiPerImpresa($data, $item);
                $result = 0;
                foreach ($dipendenti['Impiegati tecnici'] as $dipendente) {
                    $result += $dipendente['tempo_determinato'];
                }

                return $result;
            },
            "Impiegati tecnici a tempo indeterminato " => function ($data, $item) {
                $dipendenti = self::getDipendentiPerImpresa($data, $item);
                $result = 0;
                foreach ($dipendenti['Impiegati tecnici'] as $dipendente) {
                    $result += $dipendente['tempo_indeterminato'];
                }

                return $result;
            },
            "Impiegati amministrativi a tempo determinato " => function ($data, $item) {
                $dipendenti = self::getDipendentiPerImpresa($data, $item);
                $result = 0;
                foreach ($dipendenti['Impiegati amministrativi'] as $dipendente) {
                    $result += $dipendente['tempo_determinato'];
                }

                return $result;
            },
            "Impiegati amministrativi a tempo indeterminato " => function ($data, $item) {
                $dipendenti = self::getDipendentiPerImpresa($data, $item);
                $result = 0;
                foreach ($dipendenti['Impiegati amministrativi'] as $dipendente) {
                    $result += $dipendente['tempo_indeterminato'];
                }

                return $result;
            },
            "Maestranze (totale soci lavoratori e/o operai) a tempo determinato " => function ($data, $item) {
                $dipendenti = self::getDipendentiPerImpresa($data, $item);
                $result = 0;
                foreach ($dipendenti['Maestranze (totale soci lavoratori e/o operai)'] as $dipendente) {
                    $result += $dipendente['tempo_determinato'];
                }

                return $result;
            },
            "Maestranze (totale soci lavoratori e/o operai) a tempo indeterminato " => function ($data, $item) {
                $dipendenti = self::getDipendentiPerImpresa($data, $item);
                $result = 0;
                foreach ($dipendenti['Maestranze (totale soci lavoratori e/o operai)'] as $dipendente) {
                    $result += $dipendente['tempo_indeterminato'];
                }

                return $result;
            },
            "Possesso requisiti art. 38 del D.lgs 163/2006" => function ($data, $item) {
                return $data['req_ordine_gen_art38dlgs163_2006_descrizione'];
            },

            "Classifica OG 1" => function ($data, $item) {
                $categorie = self::getCategoriePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OG 1') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OG 2" => function ($data, $item) {
                $categorie = self::getCategoriePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OG 2') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OG 3" => function ($data, $item) {
                $categorie = self::getCategoriePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OG 3') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OG 4" => function ($data, $item) {
                $categorie = self::getCategoriePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OG 4') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OG 5" => function ($data, $item) {
                $categorie = self::getCategoriePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OG 5') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OG 6" => function ($data, $item) {
                $categorie = self::getCategoriePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OG 6') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OG 7" => function ($data, $item) {
                $categorie = self::getCategoriePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OG 7') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OG 8" => function ($data, $item) {
                $categorie = self::getCategoriePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OG 8') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OG 9" => function ($data, $item) {
                $categorie = self::getCategoriePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OG 9') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OG 10" => function ($data, $item) {
                $categorie = self::getCategoriePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OG 10') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OG 11" => function ($data, $item) {
                $categorie = self::getCategoriePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OG 11') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OG 12" => function ($data, $item) {
                $categorie = self::getCategoriePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OG 12') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OG 13" => function ($data, $item) {
                $categorie = self::getCategoriePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OG 13') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },

            "Classifica OS 1" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 1') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 2" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 2') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 2-A" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 2-A') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 2-B" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 2-B') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 3" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 3') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 4" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 4') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 5" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 5') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 6" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 6') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 7" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 7') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 8" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 8') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 9" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 9') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 10" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 10') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 11" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 11') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 12" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 12') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 12-A" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 12-A') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 12-B" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 12-B') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 13" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 13') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 14" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 14') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 15" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 15') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 16" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 16') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 17" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 17') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 18" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 18') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 18-A" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 18-A') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 18-B" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 18-B') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 19" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 19') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 20" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 20') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 20-A" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 20-A') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 20-B" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 20-B') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 21" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 21') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 22" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 22') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 23" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 23') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 24" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 24') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 25" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 25') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 26" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 26') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 27" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 27') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 28" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 28') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 29" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 29') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 30" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 30') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 31" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 31') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 32" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 32') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 33" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 33') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 34" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 34') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Classifica OS 35" => function ($data, $item) {
                $categorie = self::getCategorieSpecializzatePerImpresa($data, $item);
                foreach ($categorie as $categoria) {
                    if ($categoria['categoria'] == 'OS 35') {
                        return $categoria['classifica'];
                    }
                }

                return '';
            },
            "Attività" => function ($data, $item) {
                $result = array();
                foreach ((array)$data['elenco_sezione_attivita'] as $attivita) {
                    $result[] = $attivita['name']['ita-IT'];
                }

                return implode("|", array_unique($result));
            },
        );
    }
}
