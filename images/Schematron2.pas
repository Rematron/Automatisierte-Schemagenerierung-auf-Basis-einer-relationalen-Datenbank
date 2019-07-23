//-----------------------------------------------
// Generates a XML-Schematron file for the Article-Import/Export
//-----------------------------------------------
function TBMDPpsXmlValidationGenerator.AddArticleRules( uDoc: TBMDXMLDOMDocument; uParentNode: IXMLDOMNode ): Boolean;
var lPatternNode,
    lRuleNode : IXMLDOMNode;
begin
  Result := TRUE;
  lPatternNode := AddPattern(uDoc, uParentNode, 'Check ArtikelNr');
  lRuleNode := AddRule(uDoc, lPatternNode, 'ARTICLE[@GENERATE_ARTICLENO=TRUE]');
  AddAssertion(uDoc, lRuleNode, 'boolean(./ARTICLE_NO/text())', 'Wenn Attribut GENERATE_ARTICLENO=TRUE ist, darf keine ArtikelNr gesetzt sein');

end;

//------------------------------------------
// Adds a new pattern element in the XML-Schematron file
//------------------------------------------
function TBMDPpsXmlValidationGenerator.AddPattern( uDoc: TBMDXMLDOMDocument; uParentNode: IXMLDOMNode; uName : String ): IXMLDOMNode;
var lPatternNode : IXMLDOMNode;
begin
  lPatternNode := uDoc.AddNode(uParentNode, 'sch:pattern' {NodeName}, ['name'], [uName]);
  Result := lPatternNode;
end;