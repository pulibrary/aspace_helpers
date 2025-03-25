xquery version "3.0";
declare default element namespace "urn:schemas-microsoft-com:office:spreadsheet";
declare option saxon:output "omit-xml-declaration=yes";

declare variable $aclu as document-node()+ := doc("file:/Users/heberleinr/Downloads/test.xml");
let $header-row := for $cell in $aclu//Table/Row[1]/Cell return $cell
let $records :=
	for $row at $ind in subsequence($aclu//Table/Row, 2)
		let $folders-string := $row/Cell[17]/Data/string()
		let $restrictions-string := $row/Cell[18]/Data/string()
	(:parse out folders:)
		let $unittitles := 
			for $unittitle in tokenize(replace($folders-string, "(,\s)(\d{1,}\.)", "|$2"), "\|")
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
			for $restriction in tokenize(replace($restrictions-string, "(,\s)(\d{1,}\.)", "|$2"), "\|")
			return 
	(:parse out restrictions:)
				let $restriction-unnumbered := replace($restriction, "^\d{1,}\.\s", "")
				return
				if (matches($restriction-unnumbered, "^Open\s?\.?$"))
				then
					<cell label="accessrestrict">These records are open.</cell>
				else
					let $tokens := tokenize($restriction-unnumbered, "-")
					let $work-product := normalize-space($tokens[1])
					let $year := tokenize(normalize-space($tokens[2]), "\s")[2]
					return
	(:add the text as well as an extra column for the year-open.:)
					<cell label="accessrestrict">{"These records contain " || $work-product || " information. They will open in " || $year || ".^" || $year || "-01-01"}</cell>
		return
(
			<record row="{$ind+1}">{
				<cell label="level">2</cell>,
				for $cell at $no in ($row/Cell[position() = (1 to 16)])
				return
					<cell label="{$header-row/Cell[position()=$no]/string()}">{
						$cell/string()
					}</cell>
			}</record>,
		for $unittitle at $pos in $unittitles
		let $restriction := $restrictions[position() = $pos]
		return
			(:create a row for each folder:)
			<record row="{$ind+1}">{
				<cell label="level">3</cell>,
				<cell>{$unittitle}</cell>,
				for $cell at $no in ($row/Cell[position() = (2 to 7)])
				return
					<cell label="{$header-row/Cell[position()=$no]/string()}">{
						$cell/string()
					}</cell>,
				(:skip box-level date columns:)
				<cell></cell>,
				<cell></cell>,
				<cell>{$unittitle/data(@unitdate)}</cell>,
				for $cell at $no in ($row/Cell[position() = (11 to 16)])
				return
					<cell label="{$header-row/Cell[position()=$no]/string()}">{
						$cell/string()
					}</cell>,
				$unittitle, 
				$restriction
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