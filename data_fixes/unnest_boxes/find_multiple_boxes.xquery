xquery version "3.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace xlink = "http://www.w3.org/1999/xlink";

declare copy-namespaces preserve, inherit;
import module namespace functx = "http://www.functx.com"
at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";

declare variable $eads as document-node()* := collection("file:////Users/heberleinr/Documents/SVN_Working_Copies/trunk/rbscXSL/ASpace_files?select=*.xml;recurse=yes")/doc(document-uri(.));

for $ead in $eads[not(//ead:dsc[2])]
	let $components := $ead//ead:c/ead:did[count(ead:container[matches(@type, 'box|carton|volume', 'i')])>3]
	for $component in $components[ead:container[@type = following-sibling::ead:container/@type and @encodinganalog = following-sibling::ead:container/@encodinganalog]]
		let $top_container := $component/ead:container[1]
		let $siblings := <siblings>{for $sibling in $top_container/following-sibling::ead:container[@type = $top_container/@type] return $sibling/@type || ' ' || $sibling}</siblings>
			return
			normalize-space(
			$component/../@id || '^' ||
			$top_container/@type || ' ' || $top_container || '^' ||
			$siblings

) || codepoints-to-string(10)