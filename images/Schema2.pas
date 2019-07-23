function TBMDPpsXmlValidationGenerator.GetXmlSchema(uFileName, uAttrSelName: String; uAttrSel: TBMDMDAttrSelection): TBMDXMLDOMDocument;
begin
  lResult := CreatePpsSchemaDoc(lSchemaDoc, lRootNode);
  lResult := lResult and AddMainNode(lSchemaDoc, lRootNode, uAttrSelName);
  lResult := lResult and AddComplexType( lSchemaDoc, lRootNode, uAttrSelName, uAttrSel );
  lResult := lResult and AddSchematronForAttrSel( lSchemaDoc, lRootNode, uAttrSel);
  if lResult then Result := lSchemaDoc;
end;


//---------------------------------------------
// The main node is required in every import/export and is not defined in the selection
//---------------------------------------------
function TBMDPpsXmlValidationGenerator.AddMainNode(uDoc: TBMDXMLDOMDocument; uParentNode: IXMLDOMNode; uName: string): Boolean;
...............

//---------------------------------------------
// Adds a new complex-type element in the XML-Schema file
//---------------------------------------------
function TBMDPpsXmlValidationGenerator.AddComplexType( uDoc: TBMDXMLDOMDocument; uParentNode: IXMLDOMNode; uName : String; uAttrSel: TBMDMDAttrSelection ): Boolean;
begin
  Result := TRUE;
  //add base node for complex type
  lComplexNode := uDoc.AddNode(uParentNode, 'xsd:complexType' {NodeName} );
  uDoc.AddNodeAttributes(lComplexNode, ['name'], [uName+'_TYPE'], ''{ANameSpaceURI}, True{ASkipPrefix});
  //add definition-node(choice) for subnodes
  lChoiceNode := uDoc.AddNode(lComplexNode, 'xsd:choice');
  uDoc.AddNodeAttributes(lChoiceNode, ['minOccurs', 'maxOccurs'], ['0', 'unbounded'], ''{ANameSpaceURI}, True{ASkipPrefix});

  if Assigned(uAttrSel.AttributeList) then begin
    for lAttribute in uAttrSel.AttributeList.Attrs do begin
      lExpAttrSel := FXmlMd.AttrSelByNameAndId(uName, lAttribute.ConstId);
      if Assigned(lExpAttrSel) then begin
        if not ImportMode then begin
          //Create new complex node for sub attr selection
          lSimpleNode := uDoc.AddNode(lChoiceNode, 'xsd:element' {NodeName} );
          uDoc.AddNodeAttributes(lSimpleNode, ['name', 'type'], [lExpAttrSel.AttrGroupObj.UserDefinedCaptionMember, lExpAttrSel.AttrGroupObj.UserDefinedCaptionMember+'_TYPE'], ''{ANameSpaceURI}, True{ASkipPrefix});
          Result := AddComplexType(uDoc, uParentNode, lExpAttrSel.AttrGroupObj.UserDefinedCaptionMember, lExpAttrSel);
        end;
      end else begin
        //Add all possible subnodes according to attr-sel
        lSimpleNode := uDoc.AddNode(lChoiceNode {AParentNode}, 'xsd:element'{NodeName});
        uDoc.AddNodeAttributes(lSimpleNode, ['name', 'type', 'minOccurs'], [lAttribute.ListCaption, GetElementTypFromAttribute(lAttribute), '0'], ''{ANameSpaceURI}, True{ASkipPrefix});
      end;
    end;
  end;
                                                                     
  if ImportMode then begin
    Result := Result and AddDefinedSubNodes(uDoc, lChoiceNode, uParentNode, uName);
    Result := Result and AddSpecificAttributes(uDoc, lComplexNode, uAttrSel);
  end;
end;