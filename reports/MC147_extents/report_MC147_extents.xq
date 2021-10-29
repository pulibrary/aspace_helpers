xquery version "3.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace xlink = "http://www.w3.org/1999/xlink";

declare copy-namespaces preserve, inherit;
import module namespace functx = "http://www.functx.com"
at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";

declare variable $ead as document-node()* := doc("file:/Users/heberleinr/Documents/aspace_helpers/reports/MC147_20210802_135113_UTC__ead.xml");

let $components := $ead//ead:c

for $component in $components
let $unitdates := <unitdates>{for $unitdate in $component/ead:did/ead:unitdate return (
if($unitdate/@type[.='inclusive']) 
then ($unitdate/data(@type) || ' ' || $unitdate/string() || ';')
else if($unitdate/@type[.='bulk']) 
then ($unitdate/data(@type) || ' ' || $unitdate/string() || ';')
else $unitdate || ';')}</unitdates>
let $extents := <extents>{for $extent in $component/ead:did/ead:physdesc/ead:extent return $extent/data(@altrender) || '^' || $extent/string() || '^'}</extents>

return
normalize-space(
$component/data(@id) || '^' || $component/data(@level) || '^' || $component/ead:did/ead:unittitle || '^'
 || (for $unitdate in $unitdates return $unitdate) || '^'
 || (for $extent in $extents return $extent))
 || codepoints-to-string(10)