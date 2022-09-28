xquery version "3.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare variable $EAD as document-node()+ := doc("file:///Users/heberleinr/Downloads/AC364_20220920_193416_UTC__ead.xml");

(:
/repositories/4/archival_objects/1466707
/repositories/4/archival_objects/1466708
/repositories/4/archival_objects/1466709
What I would like are
URI
CID
Title
Date
Container info (including container summaries and any children)
Notes "General" and "Physical Description"
:)

for $ead in $EAD//ead:ead
let $subseries_1466707 := $EAD//ead:c[ead:did/ead:unitid[@type='aspace_uri']='/repositories/4/archival_objects/1466707']
let $subseries_1466708 := $EAD//ead:c[ead:did/ead:unitid[@type='aspace_uri']='/repositories/4/archival_objects/1466708']
let $subseries_1466709 := $EAD//ead:c[ead:did/ead:unitid[@type='aspace_uri']='/repositories/4/archival_objects/1466709']

for $components in ($subseries_1466707, $subseries_1466708, $subseries_1466709)
return 
for $component in ($components, $components//ead:c)
let $physdesc := <text>{for $physdesc in $component/ead:did/ead:physdesc/* return ($physdesc/text() || ';')}</text>
let $containers := <text>{for $container in $component/ead:did/ead:container return ($container/@type || ' ' || $container)}</text>
return 
(
$component/ead:did/ead:unitid[@type='aspace_uri'] || '^' || $component/@id || '^' || $component/ead:did/ead:unittitle || '^' || 
$component/ead:did/ead:unitdate || '^' || $component/ead:odd/ead:p || '^' || $physdesc || '^' || $containers
) || codepoints-to-string(10)