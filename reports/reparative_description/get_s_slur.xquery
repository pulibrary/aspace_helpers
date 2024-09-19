xquery version "3.0";
declare option saxon:output "omit-xml-declaration=yes";

declare variable $eads as document-node()+ := collection("file:///path/to/svn?recurse=yes;select=*.xml");

(:find all instances of a string in text nodes and return the string, XPath, collection id, and ASpace uri:)

for $match in ($eads//text())[matches(., '<text_to_find>', 'i')]
return
	(
	$match || '^' ||
	$match/../../../name() || '/' ||
	$match/../../name() || '/' ||
	$match/../name() ||
	(
	if (exists($match/node-name()))
	then
		'/' || $match/node-name()
	else
		'/text()'
	)
	|| '^' ||
	(
	if ($match/parent::c)
	then
		$match/parent::c[1]/@id
	else
		$match/ancestor::ead//eadid/text()
	) || '^' ||
	$match/ancestor::c[1]/did/unitid[@type = 'aspace_uri'] ||
	codepoints-to-string(10)
	)