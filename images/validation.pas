function TBMDMDPpsTcpXml.ValidateXmlDocument(uResponseDict:TBMDWwsPpsXmlResponse): Boolean;
var
  i: integer;
  lMsxmlDoc,
  lSchema : IXMLDOMDocument2;
  lSchemaCache: IXMLDOMSchemaCollection;
  lError: IXMLDOMParseError;
begin
  try
    lMsxmlDoc := CoDOMDocument40.Create;
    lSchema := CoDOMDocument40.Create;
    lMsxmlDoc.loadXML(XmlDoc.Xml);
    lSchemaCache := CoXMLSchemaCache40.Create;

    for i:=0 to (XmlDoc.TopNode.ChildNodes.Count -1) do begin
      lSchema.loadXML(GetValidationGen.GetXmlImportSchema(XmlDoc.TopNode.ChildNodes[i].NodeName).XML);
      lSchemaCache.add('https://www.bmd.com/module/pps-cam-maschinen-und-leitstandanbindung.html', lSchema);
    end;

    lMsxmlDoc.schemas := lSchemaCache;
    lError := lMsxmlDoc.validate;
    lMSXMLDoc := nil;
    lSchema := nil;
    Result := lError.errorCode = S_OK;
    if not Result then begin
      uResponseDict.AddErrorMessage(' Error on validating xml document: ' + lError.reason);
    end;

  except
    on E: Exception do begin
      Result := FALSE;
      uResponseDict.AddErrorMessage(' Could not validate document. Please check if MSXML 4.0 Service Pack 3 is installed!');
    end;
  end;
end;