xquery version "3.0";
declare default element namespace "urn:schemas-microsoft-com:office:spreadsheet";
declare namespace saxon = "http://saxon.sf.net/";
import module namespace functx = "http://www.functx.com" at "http://www.xqueryfunctions.com/xq/functx-1.0-doc-2007-01.xq";
declare option saxon:output "omit-xml-declaration=yes";

declare variable $EAD as document-node()+ := doc("file:/Users/heberleinr/Documents/aspace_helpers/data_fixes/agents_remediation/agent_dates.xml");

for $title in $EAD//Row/Cell[4]/Data/text()
return 
	normalize-space(
		$title || '^' || 
		$title/ancestor::Row[1]/Cell[5]/Data/text() || '^' || 
		replace($title, '^([\D\S]*)(\d{4})(\s?-\s?[\D\S]*)$', '$2') || '^' || 
		replace($title, '^([\D\S]*\s?-\s?)(\d{4})?([\D\S]*)$', '$2')
	) || codepoints-to-string(10)
