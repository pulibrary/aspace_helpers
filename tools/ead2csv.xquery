xquery version "1.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare copy-namespaces no-preserve, inherit;
declare namespace saxon = "http://saxon.sf.net/";
declare option saxon:output "omit-xml-declaration=yes";

(:import module namespace functx="http://www.functx.com" 
    at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";:)

(:Edit the variable declaration by putting the path to your EAD in between the quotes:)
(:Hint: An easy way to get the path to your input file is by right-clicking the file tab in Oxygen and selecting 'Copy Location':)
declare variable $EAD as document-node()+ := doc("file:/Users/heberleinr/Downloads/MC147_20211105_135940_UTC__ead.xml");

let $components := $EAD//ead:c[not(ead:c)]
for $component in $components
let $unitdates := 
	<unitdates>{
	for $unitdate in $component/ead:did/ead:unitdate[not(position()=last())] return ($unitdate || ', '),
	for $unitdate in $component/ead:did/ead:unitdate[position()=last()] return $unitdate
	}</unitdates>
let $containers := 
	<containers>{
	for $container in $component/ead:did/ead:container return $container/@type || ' ' || $container
	}</containers>
return

normalize-space(
$component/@id || '^' || $component/@level || '^' || $component/ead:did/ead:unittitle || '^' || $unitdates || '^' || $containers
) || codepoints-to-string(10)
