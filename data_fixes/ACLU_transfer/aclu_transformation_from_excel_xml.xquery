xquery version "3.0";
declare default element namespace "urn:schemas-microsoft-com:office:spreadsheet";
declare option saxon:output "omit-xml-declaration=yes";

declare function local:insert-cells($from as xs:integer, $to as xs:integer?, $row, $header-row)
as node()*
{
	for $cell at $no in ($row/Cell[position() = ($from to $to)])
	return
 	<cell label="{$header-row/Cell[position()=$no]/string()}">{
			$cell/string()
	}</cell>
};

declare variable $aclu as document-node()+ := doc("/Users/heberleinr/Documents/aspace_helpers/data_fixes/ACLU_transfer/test.xml");
(:pick and choose columns:)
let $header-row := 
	for $cell in $aclu//Table/Row[1]/(Cell[1]|Cell[2]|Cell[4]|Cell[6]|Cell[8]|Cell[9]|Cell[10]|Cell[15]|Cell[18])
	(:Excel XML appends two empty cells that through off the column count downstream, so we need to exclude those :)
	return $cell[not(.="")]
let $records :=
	for $row at $ind in subsequence($aclu//Table/Row, 2)
		let $folders-string := $row/Cell[17]/Data/string()
		let $restrictions-string := $row/Cell[18]/Data/string()
	(:parse out folders:)
		let $unittitles := 
			for $unittitle in tokenize(replace($folders-string, "(,\s)(\d{1,2}\.)", "|$2"), "\|")
			return 
	(:take out date at the end of the folder title and stash it for later use:)
				<cell label="unittitle"
					  unitdate="{
						if (matches($unittitle, "(.+(,|\s-)\s)((January|February|March|April|May|June|July|August|September|October|November|December)?(\s\d{1,2})?(,\s)?\d{4}(-\d{4})?\s?)?$"))
						then replace($unittitle, "(.+(,|\s-)\s)((January|February|March|April|May|June|July|August|September|October|November|December)?(\s\d{1,2})?(,\s)?\d{4}(-\d{4})?\s?)?$", "$3")
						else ""
						}">{
					replace($unittitle, "(,|\s-)\s(January|February|March|April|May|June|July|August|September|October|November|December)?(\s\d{1,2})?(,\s)?\d{4}(-\d{4})?\s?$", "")
				}</cell>
		let $restrictions := 
			for $restriction in tokenize(replace($restrictions-string, "(,\s)(\d{1,2}\.)", "|$2"), "\|")
			return 
			(:parse out restrictions:)
				let $restriction-unnumbered := replace($restriction, "^\d{1,}\.\s", "")
				return
				if (matches($restriction-unnumbered, "^Open\s?\.?$"))
				then
					<cell label="accessrestrict">These records are open.</cell>
				else
					(:replace hyphen in attorney-client, then replace it back, for the tokenization to work:)
					let $tokens := tokenize(replace($restriction-unnumbered, "(\p{L})(-)(\p{L})", "$1*$3"), "-")
					let $work-product := normalize-space(replace($tokens[1], "\*", "-"))
					let $year := tokenize(normalize-space($tokens[2]), "\s")[2]
					return
					(:add the text as well as an extra column for the year-open.:)
					<cell label="accessrestrict">{"These records contain " || $work-product || " information."|| 
							(if(matches($year, "\d{4}")) then (" They will open in " || $year || ".^" || $year || "-01-01") else () )}</cell>
		return
		(
		<record row="{$ind+1}">{
			<cell label="level">2</cell>,
				for $cell at $no in $row/(Cell[1]|Cell[2]|Cell[4]|Cell[6]|Cell[8]|Cell[9]|Cell[10]|Cell[15])
				return
			 	<cell label="{$header-row/Cell[position()=$no]/string()}">{
						$cell/string()
			}</cell>,
			if (count(distinct-values($restrictions)) = 1)
			then for $cell at $no in $row/Cell[16]
			let $distinct-restriction := distinct-values($restrictions)
			return 
				if($distinct-restriction = "These records are open.") 
				then "All records in this box are open."
				else <cell label="accessrestrict">{$distinct-restriction}</cell>
			else ()
		}</record>,
		for $unittitle at $pos in $unittitles
		let $restriction := $restrictions[position() = $pos]
		return
			(:create a row for each folder:)
			<record row="{$ind+1}">{
				<cell label="level">3</cell>,
				<cell>{$unittitle}</cell>,
				local:insert-cells(2, 2, $row, $header-row),
				local:insert-cells(4, 4, $row, $header-row),
				(:these cells are only populated on the box level:)
				<cell></cell>,
				<cell></cell>,
				<cell></cell>,
				<cell>{$unittitle/data(@unitdate)}</cell>,
				local:insert-cells(15, 15, $row, $header-row),
				if (count(distinct-values($restrictions)) = 1)
				then ""
				else $restriction
			}</record>
)
		return
		(
		"level^" || string-join($header-row, "^") || "^Opens",
		codepoints-to-string(10),
		for $record in $records 
		return
			(
			string-join($record/cell, "^"),
			codepoints-to-string(10)
			)
		)