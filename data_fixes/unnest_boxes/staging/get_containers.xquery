xquery version "3.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace xlink = "http://www.w3.org/1999/xlink";

declare copy-namespaces preserve, inherit;
import module namespace functx = "http://www.functx.com"
at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";

declare variable $containers as document-node()* := doc("file:/Users/heberleinr/Documents/SVN_Working_Copies/trunk/rbscXSL/ASpace_tools/helpers/top_containers.xml");

for $container in $containers//c[container[@type="box"]]
let $location := $container/physloc[@type='code']
return
$container/@id || '^' ||
substring-before($container/@id, '_') || '^' ||
$container/container/@type || '^' ||
$container/container || '^' ||
$container/unitid[@type="barcode"] || '^' ||
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
(:hard-coding profile uri, since they were all assigned B:)
'/container_profiles/3' || '^' ||
substring-before($container/@id, '_') || '_' || $container/container/@type || '_' || $container/container || codepoints-to-string(10)

