xquery version "3.0";
declare option saxon:output "omit-xml-declaration=yes";

declare variable $ead as document-node()+ := collection("path/to/svn");

for $match in ($ead//*[not(element())]/text() | //@*)[contains(., 'libweb2.princeton.edu')]
return 
(
$match || '^' ||
$match/../../../name() || '/' ||
$match/../../name() || '/' ||
$match/../name() || 
(
if (exists($match/node-name())) 
then  '/' || $match/node-name()
else '/text()'
)
|| '^' ||
(
if ($match/parent::c) 
then $match/parent::c[1]/@id 
else $match/ancestor::ead//eadid/text()
) || '^' ||
$match/parent::c[1]/did/unitid/@type[.='aspace-uri'] ||
codepoints-to-string(10)
)