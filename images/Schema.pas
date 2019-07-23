function TBMDPpsXmlValidationGenerator.GenerateXmlImportSchema(uAttrSelName: String): Boolean;
begin
  Result := GenerateXmlSchema(lFileName, uAttrSelName, lObj.FAttrSel);
end;

function TBMDPpsXmlValidationGenerator.GenerateXmlExportSchema(uConstId: TBMDId): Boolean;
....................

function TBMDPpsXmlValidationGenerator.GenerateXmlSchema(uFileName, uAttrSelName: String; uAttrSel: TBMDMDAttrSelection): Boolean;
begin
  lFullPath := ThePpsGc.PpsIntParamMd.IntSchemaSavePath + uFileName;
  Result := ForceDirectories(lFullPath);

  Result := Result and CreatePpsSchemaDoc(lSchemaDoc, lRootNode);
  Result := Result and AddMainNode(lSchemaDoc, lRootNode, uAttrSelName);
  Result := Result and AddComplexType( lSchemaDoc, lRootNode, uAttrSelName, uAttrSel );
  Result := Result and AddSchematronForAttrSel( lSchemaDoc, lRootNode, uAttrSel);
  Result := Result and lSchemaDoc.SaveToFile(lFullPath);

  if Result then begin
    DisplayProgress('Saved schema to: ' + lFullPath);
    FStatus := 'OK';
  end else begin
    FStatus := 'NOT_OK';
  end;
end;

function TBMDPpsXmlValidationGenerator.GetXmlImportSchema(uAttrSelName: String): TBMDXMLDOMDocument;
begin
  ImportMode := TRUE;

  lObj := TBMDWWSPPSProcessRegObj( FXmlMd.GetRegAttrSelections4Import.ObjByString[ uAttrSelName ] );
  lFileName := 'BMDPPS_' + uAttrSelName + '_IMPORT.xsd';
  DisplayProgress('Generating import schema for element: ' + uAttrSelName);

  Result := GetXmlSchema(lFileName, uAttrSelName, lObj.FAttrSel);
end;