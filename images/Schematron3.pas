//------------------------------------------
// Adds a new rule element in the XML-Schematron file
//-----------------------------------------
function TBMDPpsXmlValidationGenerator.AddRule( uDoc: TBMDXMLDOMDocument; uParentNode: IXMLDOMNode; uContext : String ): IXMLDOMNode;
var lRuleNode : IXMLDOMNode;
begin
  lRuleNode := uDoc.AddNode(uParentNode, 'sch:pattern' {NodeName}, ['context'], [uContext]);
  Result := lRuleNode;
end;

//----------------------------------------
// Adds a new assertion element in the XML-Schematron file
//----------------------------------------
function TBMDPpsXmlValidationGenerator.AddAssertion( uDoc: TBMDXMLDOMDocument; uParentNode: IXMLDOMNode; uTest, uMessage : String ): IXMLDOMNode;
var lAssertionNode : IXMLDOMNode;
begin
  lAssertionNode := uDoc.AddNode(uParentNode, 'sch:assert' {NodeName}, uMessage {Text}, ['test'], [uTest]);
  Result := lAssertionNode;
end;            
