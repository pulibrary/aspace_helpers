xquery version "3.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace xlink = "http://www.w3.org/1999/xlink";

declare copy-namespaces preserve, inherit;
import module namespace functx = "http://www.functx.com"
at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";

declare variable $eads as document-node()* := collection("file:///Users/heberleinr/Documents/SVN_Working_Copies/trunk/eads/mudd/univarchives?select=*.xml;recurse=yes")/doc(document-uri(.));

let $selection := $eads[starts-with(//ead:eadid, 'AC107')]
let $containers := $selection//ead:container[@type='box']/text()

for $each in distinct-values($containers)
order by $each
return $each || codepoints-to-string(10)