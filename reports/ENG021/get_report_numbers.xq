xquery version "3.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace xlink = "http://www.w3.org/1999/xlink";

declare copy-namespaces preserve, inherit;
import module namespace functx = "http://www.functx.com"
at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";

declare variable $ead as document-node()* := doc("file:/Users/heberleinr/Downloads/ENG021_20230306_224646_UTC__ead.xml?select=*.xml;recurse=yes");


for $c in $ead//ead:c/ead:did 
let $creators := 
	<creators>
	{
	for $creator in $c/ead:origination/*[@role="aut"] return
	($creator || '; ')
	}
	</creators>
	return 
	normalize-space(
	$c/../@id || '^' || $c/ead:unittitle || '^' || $creators || '^' || $c/ead:container
	
	) || codepoints-to-string(10)
