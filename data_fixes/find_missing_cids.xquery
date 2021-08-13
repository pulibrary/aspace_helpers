xquery version "3.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare namespace xlink = "http://www.w3.org/1999/xlink";

declare copy-namespaces preserve, inherit;
import module namespace functx = "http://www.functx.com"
at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";

declare variable $eads as document-node()* := collection("file:///Users/heberleinr/Documents/SVN_Working_Copies/trunk/rbscXSL/ASpace_files?select=*.xml;recurse=yes")/doc(document-uri(.));

let $components := $eads//ead:c[not(@id)]

for $component in $components return
normalize-space(
$component/ead:did/ead:unittitle || '^' || $component/ead:did/ead:unitdate[1] || '^' || $component/ead:accessrestrict/data(@type) || '^' || $component/ead:accessrestrict/data(@altrender) || '^' || $component/ancestor::ead:c[@id][1]/data(@id) || '^' )|| codepoints-to-string(10)