xquery version "3.1";
declare namespace serialize = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option serialize:item-separator "&#xa;";
declare option saxon:output "omit-xml-declaration=yes";
declare variable $input as document-node()* := collection("/Users/heberleinr/Documents/libsvn/eads/lae");


for $i in $input//ead
let $eadid := $i//eadid,
$physlocs := <physloc>{for $physloc in $i//archdesc/did/physloc return <p>{$physloc}</p>}</physloc>,
$related := $i//altformavail
order by $eadid
return
$eadid || "^" || (for $p in $physlocs/p return ($p || "^" )) || normalize-space($related)