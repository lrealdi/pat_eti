<div class="media-panel">

  {def $icon = ezini( 'ClassIcons', $node.object.class_identifier, 'fa_icons.ini.append.php' )}

  {def $pdf_obj = $node.object}

  <div class="media">
    <div class="caption">

        <div class="row">
            <div class="col-xs-10">
                <h4 class="fw_medium color_dark">
                    <a href="{$openpa.content_link.full_link}" title="{$node.name|wash()}">
                        <p>{$node.data_map.nome.content} {$node.data_map.cognome.content}</p>
                        <small>{attribute_view_gui attribute=$node|attribute( 'data_nascita' )}</small>
                    </a>

                </h4>
            </div>
            <div class="col-xs-2">
                <h1 style="margin-top: -5px;">
                    <i class="fa {$icon} d_inline_middle"></i>
                </h1>
            </div>
        </div>

        <div class="row">
            <div class="col-xs-8">
                <a href={concat("content/download/",
                $pdf_obj.id,
                "/",
                $pdf_obj.data_map.pdf.id,
                "/file/",
                $pdf_obj.data_map.pdf.content.original_filename)|ezurl} target="_blank">
                    <img src={$node.data_map.pdf_preview.content[original].full_path|ezroot()} width="200" height="250" style="border: 1px solid #73B9FF"/>
                </a>
            </div>
            <div class="col-xs-4">
                <p class="link">
                    <a href="{$openpa.content_link.full_link}" title="{$node.name|wash()}">Dettaglio</a>
                </p>
                <p></p>
                <p class="link">
                    <a href={concat("content/download/",
                    $pdf_obj.id,
                    "/",
                    $pdf_obj.data_map.pdf.id,
                    "/file/",
                    $pdf_obj.data_map.pdf.content.original_filename)|ezurl} target="_blank"> PDF</a>
                </p>
            </div>
        </div>

    </div>
  </div>
</div>