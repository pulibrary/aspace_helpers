xquery version "3.0";
declare default element namespace "urn:schemas-microsoft-com:office:spreadsheet";
declare namespace saxon = "http://saxon.sf.net/";
import module namespace functx = "http://www.functx.com" at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";
declare option saxon:output "omit-xml-declaration=yes";

declare variable $EAD as document-node()+ := doc("file:/Users/heberleinr/Documents/aspace_helpers/data_fixes/agents_remediation/agent_dates.xml");

for $title in $EAD//Row/Cell[4]/Data/text()
let $computed_date :=
	if (matches($title, '^([\D\S]*?)(\d{4})(-)(\d{4})?([\D\S]*?)$'))
	then
		(:date range:)
		replace($title, '^([\D\S]*?)(\d{4})(-)(\d{4})?([\D\S]*?)$', '$2^$4')
	else if (matches($title, '^([\D\S]*?b\.\s?)(\d{4})([\D\S]*?)$'))
	then
		(:b. date:)
		replace($title, '^([\D\S]*?b\.\s?)(\d{4})([\D\S]*?)$', '$2') 
	else if (matches($title, '^([\D\S]*?(d\.|-)\s?)(\d{4})([\D\S]*?)$'))
	then
		(:d. date:)
		replace($title, '^([\D\S]*?(d\.|-)\s?)(\d{4})([\D\S]*?)$', '^$3')
	else()
return 
	normalize-space(
		$title || '^' || 
		$title/ancestor::Row[1]/Cell[3]/Data/text() || '^' || 
		$computed_date
	) || codepoints-to-string(10)
