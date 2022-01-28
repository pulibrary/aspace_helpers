xquery version "3.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace xlink = "http://www.w3.org/1999/xlink";

declare copy-namespaces preserve, inherit;
import module namespace functx = "http://www.functx.com"
at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";

declare variable $eads as document-node()* := doc("file:/Users/heberleinr/Documents/aspace_helpers/reports/MC147_Gale_cids/MC147_export.xml");

for $ead in $eads
let $records := $ead//record

for $record in $records
let $folder-range := tokenize($record/container[matches($record, "folder.+-")], "\s")[4]

return
	if($folder-range)
	then
		for $number in tokenize($folder-range, "-")[1] cast as xs:integer to tokenize($folder-range, "-")[2] cast as xs:integer
		let $container := substring-before($record/container, $folder-range)
		return 
			normalize-space(
			$record/uri || '^' || $record/cid || '^' || $record/unittitle || '^' || $record/unitdate || '^' || $container || $number
			) || codepoints-to-string(10)
	else 
		normalize-space(
		$record/uri || '^' || $record/cid || '^' || $record/unittitle || '^' || $record/unitdate || '^' || $record/container
		) || codepoints-to-string(10)
