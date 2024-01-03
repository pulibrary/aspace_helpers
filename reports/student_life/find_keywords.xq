xquery version "3.0";
declare namespace ead = "urn:isbn:1-931666-22-9";
declare copy-namespaces no-preserve, inherit;

import module namespace functx = "http://www.functx.com"
at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";

declare variable $EADS as document-node()* := collection("/Users/heberleinr/Downloads/student_fas?recurse=yes;select=*.xml")/doc(document-uri(.));

for $EAD in $EADS
let $components := $EAD//ead:c//*[not(self::ead:c)]/text()[matches(., 'demonstration|protest|association|organization|club|society')]

for $component in $components
let $component-id := $component/ancestor::ead:c[1]/@id
let $found-in := $component/../../name() || "/" || $component/../name()
let $text := $component/../string()
return
$component-id || '^' || $found-in || '^' || $text || codepoints-to-string(10)
