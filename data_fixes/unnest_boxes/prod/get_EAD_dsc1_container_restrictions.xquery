xquery version "3.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace xlink = "http://www.w3.org/1999/xlink";

declare copy-namespaces preserve, inherit;
import module namespace functx = "http://www.functx.com"
at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";

declare variable $eads as document-node()* := collection("file:////Users/heberleinr/Documents/SVN_Working_Copies/trunk/rbscXSL/ASpace_files?select=*.xml;recurse=yes")/doc(document-uri(.));
for $ead in $eads
(:get only containers that were not entified or might have been improperly entified:)
	let $dids := $ead//ead:did[ead:container[@type='box' and not(@label) or contains(@label, '_n')]]
	for $did in $dids
		let $boxes := $did/ead:container[@type='box']
		for $box in $boxes
		let $ead-container-string := $ead//ead:eadid || '_' || $box/@type || '_' || $box

		return
		normalize-space(
		$box/ancestor::ead:c[1]/@id || '^' || 
		substring-after(substring-before($box/@label, ']'), '[') || '^' ||
		$ead-container-string || '^' || 
		$box/ancestor::ead:c[1]/ead:accessrestrict/@type || '^' || 
		$box/ancestor::ead:c[1]/ead:accessrestrict/@altrender || '^' || 
		$box/ancestor::ead:c[1]/ead:accessrestrict
		) ||
		codepoints-to-string(10)