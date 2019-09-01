function TBMDPpsXmlValidationGenerator.CreatePpsSchemaDoc(var vSchemaDoc : TBMDXMLDOMDocument; var vRootNode: IXMLDOMNode): Boolean;
begin
  if (vSchemaDoc = NIL) and (vRootNode = NIL) then begin
    vSchemaDoc := TBMDXMLDOMDocument.Create(Self);
    vSchemaDoc.SetDocHeader(XML_SCHEMA_VERSION, XML_SCHEMA_ENCODING);
    vRootNode := vSchemaDoc.AddNode(NIL, XML_SCHEMA_ROOTNAME);
    vSchemaDoc.AddNodeAttributes(vRootNode,
                                ['xmlns:xsd', 'targetNamespace', 'xmlns', 'elementFormDefault'],
                                [XML_SCHEMA_XSDNAMESPACE, XML_SCHEMA_PPSNAMESPACE, XML_SCHEMA_PPSNAMESPACE, XML_SCHEMA_ELEMENTFORM],
                                ''{ANameSpaceURI}, True{ASkipPrefix});
  end;
  Result := Assigned(vSchemaDoc) and Assigned(vRootNode);
end;

//-----------------------------------------------
// Implement specific node attribute that are specified according to CAM-Interface documentation
//-----------------------------------------------
function TBMDPpsXmlValidationGenerator.AddSpecificAttributes( uDoc: TBMDXMLDOMDocument; uParentNode: IXMLDOMNode; uAttrSel: TBMDMDAttrSelection ): Boolean;
begin
  Result := TRUE;
  if (uAttrSel.AttrGroup.MasterGroup = 60004056) and (uAttrSel.AttrGroup.SubGroup = 7) then begin
    AddArticleAttributes( uDoc, uParentNode );
  end;
end;

function TBMDPpsXmlValidationGenerator.AddDefinedSubNodes(uDoc: TBMDXMLDOMDocument; uParentNode, uTypeParentNode: IXMLDOMNode; uAttrSelName: string): Boolean;
begin
  lObj := TBMDWWSPPSProcessRegObj( FXmlMd.GetRegAttrSelections4Import.ObjByString[ uAttrSelName ] );
  for lAllowedSubNode in lObj.AllowedSubNodes do begin
    if Result and FXmlMd.GetRegAttrSelections4Import.Find(lAllowedSubNode, i) then begin
      lSimpleNode := uDoc.AddNode(uParentNode, 'xsd:element' {NodeName} );
      uDoc.AddNodeAttributes(lSimpleNode, ['name', 'type'], [lAllowedSubNode, lAllowedSubNode+'_TYPE'], ''{ANameSpaceURI}, True{ASkipPrefix});
      Result := AddComplexType( uDoc, uTypeParentNode, lAllowedSubNode, FXmlMd.AttrSelByNodeName(lAllowedSubNode) );
    end;
  end;      
end;