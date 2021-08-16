xquery version "3.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace xlink = "http://www.w3.org/1999/xlink";

declare copy-namespaces preserve, inherit;
import module namespace functx = "http://www.functx.com"
at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";

declare variable $eads as document-node()* := collection("file:///Users/heberleinr/Documents/SVN_Working_Copies/trunk/rbscXSL/aspace_files?select=*.xml;recurse=yes")/doc(document-uri(.));

let $accessrestricts := $eads//ead:dsc[1]//ead:accessrestrict[@altrender]/@altrender

for $a in $accessrestricts return
$a/ancestor::ead:c[1]/data(@id) || ' ' || data($a) || codepoints-to-string(10)