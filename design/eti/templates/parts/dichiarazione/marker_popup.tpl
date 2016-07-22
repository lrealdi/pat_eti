{def $object = fetch(content,object,hash('object_id', $object_id))}
<p>
    <strong>{$object.main_node.parent.name|wash()}</strong>
</p>

<p>
    {$object.name|wash()}
</p>
