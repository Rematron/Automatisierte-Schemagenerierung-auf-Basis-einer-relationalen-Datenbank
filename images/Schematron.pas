//--------------------------------------
// Add a XML-Schematron notation (.xsd) for a specific attribute-selection
//--------------------------------------
function TBMDPpsXmlValidationGenerator.AddSchematronForAttrSel(uDoc:TBMDXMLDOMDocument; uParentNode: IXMLDOMNode; uAttrSel: TBMDMDAttrSelection): Boolean;
var lAnnotation,
    lAppInfo   : IXMLDOMNode;
begin
  Result := TRUE;
  //Is a Schematron implemented?
  if (uAttrSel.AttrGroup.MasterGroup = 60004056) and (uAttrSel.AttrGroup.SubGroup = 7) then begin
    uDoc.AddNodeAttributes(uParentNode, ['xmlns:sch'], [XML_SCHEMATRON_NAMESPACE], ''{ANameSpaceURI}, True{ASkipPrefix});
    lAnnotation := uDoc.AddNode(uParentNode, 'xsd:annotation' {NodeName} );
    lAppInfo := uDoc.AddNode(lAnnotation, 'xsd:appinfo' {NodeName} );
    Result := AddArticleRules( uDoc, lAppInfo );
    if Result then
      DisplayProgress('Saved schematron information correctful');
  end;
end;
