xquery version "3.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace xlink = "http://www.w3.org/1999/xlink";

declare copy-namespaces preserve, inherit;
import module namespace functx = "http://www.functx.com"
at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";

declare variable $eads as document-node()* := collection("file:////Users/heberleinr/Documents/SVN_Working_Copies/trunk/rbscXSL/ASpace_files?select=*.xml;recurse=yes")/doc(document-uri(.));

for $ead in $eads
let $records := $ead//record
let $folder-range := for $record in $records return substring-after(., "folder ")

for $record in $records
return
	if(contains($record/container, "folder"))
	then
		for $number in tokenize($folder-range, "-")[1] cast as xs:integer to tokenize($folder-range, "-")[2] cast as xs:integer
		return 
			$record/uri || '^' || $record/cid || '^' || $record/unittitle || '^' || $record/untidate || '^' || $record/container || codepoints-to=string(10)
	else $record/uri || '^' || $record/cid || '^' || $record/unittitle || '^' || $record/untidate || '^' || $record/container || codepoints-to=string(10)
