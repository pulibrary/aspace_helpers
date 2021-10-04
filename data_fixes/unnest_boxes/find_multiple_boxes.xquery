xquery version "3.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace xlink = "http://www.w3.org/1999/xlink";

declare copy-namespaces preserve, inherit;
import module namespace functx = "http://www.functx.com"
at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";

declare variable $eads as document-node()* := collection("file:////Users/heberleinr/Documents/SVN_Working_Copies/trunk/rbscXSL/ASpace_files?select=*.xml;recurse=yes")/doc(document-uri(.));
declare variable $containers as document-node()* := doc("file:/Users/heberleinr/Documents/SVN_Working_Copies/trunk/rbscXSL/ASpace_tools/helpers/top_containers.xml");

for $ead in $eads
let $components := $ead//ead:c/ead:did[count(ead:container[matches(@type, 'box', 'i')]) > 1]
let $distinct-siblings := distinct-values($components/ead:container[@type = preceding-sibling::ead:container/@type
and @encodinganalog = preceding-sibling::ead:container/@encodinganalog
and contains(@encodinganalog, '_n')])
for $component in $components[ead:container[@type = following-sibling::ead:container/@type
and @encodinganalog = following-sibling::ead:container/@encodinganalog
and contains(@encodinganalog, '_n')]]
let $top_container := $component/ead:container[1]
let $siblings :=
<siblings>{
		for $sibling in $top_container/following-sibling::ead:container[@type = $top_container/@type]
		let $encodinganalog := $sibling/@encodinganalog
		let $position := index-of($distinct-siblings, $sibling)
		let $restriction-alt := $sibling/../following-sibling::ead:accessrestrict/@altrender
		let $restriction-type := $sibling/../following-sibling::ead:accessrestrict/@type
		let $restriction-note := $sibling/../following-sibling::ead:accessrestrict
		
		return
			<sibling
				encodinganalog='{$encodinganalog}'
				position='{$position}'
				type='{$sibling/@type}'
				local_access_restriction_type='{$restriction-alt}'
				notes_type='{$restriction-type}'
				notes_content='{$restriction-note}'
			>{$sibling}
			</sibling>
	}</siblings>
for $sibling in $siblings/*
let $id := xs:integer(substring-after($sibling/@encodinganalog, '_n')) + $sibling/@position
let $location := $containers//c[@id = $sibling/@encodinganalog or contains($sibling/@label, @id)]/physloc[@type[. = 'code']]
return
	normalize-space(
	$component/../@id || '^' ||
	$top_container/@type || ' ' || $top_container || '^' ||
	$top_container/@encodinganalog || '^' ||
	$top_container/@label || '^' ||
	$sibling/@type || '^' ||
	$sibling || '^' ||
	$sibling/@position || '^' ||
	substring-before($sibling/@encodinganalog, '_n') || '_n' || $id || '^' ||
	(if ($location = 'mss')
	then
		'/locations/23648'
	else
		if ($location = 'mudd')
		then
			'/locations/23649'
		else
			if ($location = 'rcpph')
			then
				'/locations/23652'
			else
				if ($location = 'rcpxm')
				then
					'/locations/23657'
				else
					if ($location = 'rcpxr')
					then
						'/locations/23658'
					else
						if ($location = 'review')
						then
							'/locations/23662'
						else
							$location
	) || '^' ||
	(:	$containers//c[@id=$sibling/@encodinganalog or contains($sibling/@label, @id)]/physloc[@type[.='profile']]
:)
	(:hard-coding profile uri, since they were all assigned B:)
	'/container_profiles/3' || '^' ||
	$sibling/@local_access_restriction_type || '^' ||
	$sibling/@notes_type || '^' ||
	$sibling/@notes_content
	) || codepoints-to-string(10)