{def $object = fetch(content,object,hash('object_id', $object_id))
	 $parent = $object.main_node.parent}
<p>
     <a href="{$parent.url_alias|ezurl(no)}"><strong>{$parent.name|wash()}</strong></a>
</p>

<p>
   {$object.name|wash()}
</p>
