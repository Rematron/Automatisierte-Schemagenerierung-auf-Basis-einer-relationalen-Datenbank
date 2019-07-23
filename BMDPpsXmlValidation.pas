//--------------------------------------------------------------------------------------------------
//  (c) BMD Systemhaus Software - Delphi Implementation File
//--------------------------------------------------------------------------------------------------
// Owner:       REN582
// Paket:       PPS
// Project:     <2165020>
//--------------------------------------------------------------------------------------------------
// Last Commit:
//     $Author: REN582 $
//        $Rev: 775699 $
//       $Date: 2019-01-04 08:39:38 +0100 (Fr, 04 Jan 2019) $
//        $URL: http://bmdntcs-srv:81/svn/ntcs/Trunk/Sourcen/Pps/BMDPpsXmlValidation.pas $
//--------------------------------------------------------------------------------------------------

unit BMDPpsXmlValidation;

{$IFDEF BMDISPACKAGE}
  {$IFNDEF BMDPPSDYNAMICCOMMON}
     {$MESSAGE FATAL 'Diese Unit gehört in Package BMDPPSDYNAMICCOMMON.inc!'}
  {$ENDIF}
{$ENDIF}
{$I BMDCompilers.inc}

interface

uses
  SysUtils, Classes, Controls,
  //Tools
  BMDConst,
  BMDTypes,
  BMDAttrList,
  BMDAttribute,
  BMDController,
  BMDStringList,
  BMDXmlDOMDocument,
  BMDAttrSelectionMD,
  //Wws
  BMDWwsTypes,
  //Pps
  BMDPpsInterfaces,    
  BMDWwsPpsBaseXmlMD,
  BMDWwsPpsXmlObjects;

type

  //forward declarations
  TBMDPpsXmlValidationGenerator = class;

  //-----------------------------------------------------------------
  // Name:        TBMDPpsXmlValidationGenerator
  //-----------------------------------------------------------------
  TBMDPpsXmlValidationGenerator = class(TBMDModel, IBMDMDPpsXmlValidationGenerator)
  private
  protected
    FStatus     : String;
    FError      : String;
    FImportMode : Boolean;
    FDoDisplay  : TBMDDoDisplayAbortEvent;
    FAttrSelList: TBMDStringList;
    FExpRegObj  : TBMDWwsPpsXmlRegObj;
    FXmlMd      : TBMDWWSPPSBaseXmlMD;


    function    GetError: String;
    procedure   SetError(uValue: String);
    function    GetStatus: String;
    procedure   SetStatus(uValue: String);
    function    GetDoDisplay: TBMDDoDisplayAbortEvent;
    procedure   SetDoDisplay(uEvent: TBMDDoDisplayAbortEvent);
    function    GetImportMode: Boolean;
    procedure   SetImportMode(uValue: Boolean);


    function    DisplayProgress(uDisplay: String): Boolean;
    function    CreatePpsSchemaDoc(var vSchemaDoc : TBMDXMLDOMDocument; var vRootNode: 
    IXMLDOMNode): Boolean;

    function    GenerateXmlImportSchema(uAttrSelName: String): Boolean;
    function    GenerateXmlExportSchema(uConstId: TBMDId): Boolean;
    function    GetXmlImportSchema(uAttrSelName: String): TBMDXMLDOMDocument;
    function    GetXmlExportSchema(uConstId: TBMDId): TBMDXMLDOMDocument;
    function    GenerateXmlSchema(uFileName, uAttrSelName: String; uAttrSel: 
    TBMDMDAttrSelection): Boolean;
    function    GetXmlSchema(uFileName, uAttrSelName: String; uAttrSel: 
    TBMDMDAttrSelection): TBMDXMLDOMDocument;

    function    AddMainNode(uDoc: TBMDXMLDOMDocument; uParentNode: IXMLDOMNode; 
    uName: string): Boolean;
    function    AddComplexType( uDoc: TBMDXMLDOMDocument; uParentNode: IXMLDOMNode; 
    uName : String; uAttrSel: TBMDMDAttrSelection): Boolean;
    function    GetElementTypFromAttribute( uAttribute: TBMDAttribute ): String;
    function    AddSpecificAttributes( uDoc: TBMDXMLDOMDocument; uParentNode: 
    IXMLDOMNode; uAttrSel: TBMDMDAttrSelection ): Boolean;
    function    AddDefinedSubNodes(uDoc: TBMDXMLDOMDocument; uParentNode, uTypeParentNode: 
    IXMLDOMNode; uAttrSelName: string): Boolean;


    procedure   AddArticleAttributes( uDoc: TBMDXMLDOMDocument; uParentNode: IXMLDOMNode );
    function    AddArticleRules( uDoc: TBMDXMLDOMDocument; uParentNode: IXMLDOMNode ): Boolean;

    function    AddSchematronForAttrSel(uDoc:TBMDXMLDOMDocument; uParentNode: IXMLDOMNode; 
    uAttrSel: TBMDMDAttrSelection ): Boolean;
    function    AddPattern( uDoc: TBMDXMLDOMDocument; uParentNode: IXMLDOMNode; uName : 
    String ): IXMLDOMNode;
    function    AddRule( uDoc: TBMDXMLDOMDocument; uParentNode: IXMLDOMNode; uContext : 
    String ): IXMLDOMNode;
    function    AddAssertion( uDoc: TBMDXMLDOMDocument; uParentNode: IXMLDOMNode; uTest, 
    uMessage : String ): IXMLDOMNode;


  public
    constructor Create( uOwner : TComponent ); override;     
    destructor  Destroy; override;

    property    ImportMode   : Boolean                      read GetImportMode    
    write SetImportMode;
    property    Status       : String                       read GetStatus        
    write SetStatus;
    property    Error        : String                       read GetError         
    write SetError;
    property    DoDisplay    : TBMDDoDisplayAbortEvent      read GetDoDisplay     
    write SetDoDisplay;
  end;


implementation

uses
  BMDTools,
  BMDWwsPpsBueroTools,
  BMDPpsGlobalCoordinator;

const
  XML_SCHEMA_VERSION = '2.0';
  XML_SCHEMA_ENCODING = 'ISO-8859-1';
  XML_SCHEMA_ROOTNAME = 'xsd:schema';
  XML_SCHEMA_XSDNAMESPACE = 'http://www.w3.org/2001/XMLSchema';
  XML_SCHEMA_PPSNAMESPACE = 'https://www.bmd.com/module/pps-cam-maschinen-und-
  leitstandanbindung.html';
  XML_SCHEMA_ELEMENTFORM = 'qualified';

  XML_SCHEMATRON_NAMESPACE = 'http://www.ascc.net/xml/schematron';


//------------------------------------------------------------------------------
constructor TBMDPpsXmlValidationGenerator.Create(uOwner: TComponent);
begin
  inherited;

  FStatus := BNS;
  FError  := BNS;
  FDoDisplay := NIL;
  FImportMode := FALSE;
  FXmlMd := uOwner as TBMDWWSPPSBaseXmlMD;

  if FXmlMd = NIL then begin
    FXmlMd := TheClassFactory().CreateInstance(MC_MDPPS_XMLMD) as TBMDWWSPPSBaseXmlMD;
    FXmlMd.InitRegisterNodes;
  end;
end;

//------------------------------------------------------------------------------
destructor TBMDPpsXmlValidationGenerator.Destroy;
begin
  FDoDisplay := NIL;
  FXmlMd := NIL;
  inherited Destroy;
end;

//------------------------------------------------------------------------------
function TBMDPpsXmlValidationGenerator.GenerateXmlImportSchema(uAttrSelName: String): Boolean;
var lFileName  : string;
    lObj: TBMDWWSPPSProcessRegObj;
begin
  ImportMode := TRUE;

  lObj := TBMDWWSPPSProcessRegObj( FXmlMd.GetRegAttrSelections4Import.ObjByString[ uAttrSelName ] );
  lFileName := 'BMDPPS_' + uAttrSelName + '_IMPORT.xsd';
  DisplayProgress('Generating import schema for element: ' + uAttrSelName);

  Result := GenerateXmlSchema(lFileName, uAttrSelName, lObj.FAttrSel);
end;

//------------------------------------------------------------------------------
function TBMDPpsXmlValidationGenerator.GenerateXmlExportSchema(uConstId: TBMDId): Boolean;
var lFileName  : string;
    lAttrSel: TBMDMDAttrSelection;
begin
  ImportMode := FALSE;

  lAttrSel := FXmlMd.AttrSelByNameAndId('MAIN', uConstId);
  lFileName := 'BMDPPS_' + lAttrSel.AttrGroupObj.UserDefinedCaptionMember + '_EXPORT.xsd';
  DisplayProgress('Generating export schema for element: ' + 
  lAttrSel.AttrGroupObj.UserDefinedCaptionMember);

  Result := GenerateXmlSchema(lFileName, lAttrSel.AttrGroupObj.UserDefinedCaptionMember, 
  lAttrSel);
end;

//------------------------------------------------------------------------------
function TBMDPpsXmlValidationGenerator.GenerateXmlSchema(uFileName, uAttrSelName: String; 
uAttrSel: TBMDMDAttrSelection): Boolean;
var lFullPath : String;
    lSchemaDoc : TBMDXMLDOMDocument;
    lRootNode: IXMLDOMNode;
begin
  lSchemaDoc := NIL;
  lRootNode  := NIL;
  lFullPath := ThePpsGc.PpsIntParamMd.IntSchemaSavePath;
  if (lFullPath = BNS) then
    lFullPath := IncludeTrailingPathDelimiter(GetUserParamValueDef(CSH_PROD_GLOBALPARAMS,
                    CS_PAR_PROD_GLOB_GRP_XMLINT, CS_PAR_PROD_GLOB_XMLINT_EXPORT_DIR, BNS, 
                    GetStdFirmenNr(PPS_NR)));;

  Result := ForceDirectories(lFullPath);
  lFullPath := lFullPath + uFileName;

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
var lFileName  : string;
    lObj: TBMDWWSPPSProcessRegObj;
begin
  ImportMode := TRUE;

  lObj := TBMDWWSPPSProcessRegObj( FXmlMd.GetRegAttrSelections4Import.ObjByString[ uAttrSelName ] );
  lFileName := 'BMDPPS_' + uAttrSelName + '_IMPORT.xsd';
  DisplayProgress('Generating import schema for element: ' + uAttrSelName);

  Result := GetXmlSchema(lFileName, uAttrSelName, lObj.FAttrSel);
end;

function TBMDPpsXmlValidationGenerator.GetXmlExportSchema(uConstId: TBMDId): TBMDXMLDOMDocument;
var lFileName  : string;
    lAttrSel: TBMDMDAttrSelection;
begin
  ImportMode := FALSE;

  lAttrSel := FXmlMd.AttrSelByNameAndId('MAIN', uConstId);
  lFileName := 'BMDPPS_' + lAttrSel.AttrGroupObj.UserDefinedCaptionMember + '_EXPORT.xsd';
  DisplayProgress('Generating export schema for element: ' + 
  lAttrSel.AttrGroupObj.UserDefinedCaptionMember);

  Result := GetXmlSchema(lFileName, lAttrSel.AttrGroupObj.UserDefinedCaptionMember, lAttrSel);
end;

//------------------------------------------------------------------------------
function TBMDPpsXmlValidationGenerator.GetXmlSchema(uFileName, uAttrSelName: String; 
uAttrSel: TBMDMDAttrSelection): TBMDXMLDOMDocument;
var lSchemaDoc : TBMDXMLDOMDocument;
    lRootNode: IXMLDOMNode;
    lResult: Boolean;
begin
  lSchemaDoc := NIL;
  lRootNode  := NIL;
  Result := NIL;

  lResult := CreatePpsSchemaDoc(lSchemaDoc, lRootNode);
  lResult := lResult and AddMainNode(lSchemaDoc, lRootNode, uAttrSelName);
  lResult := lResult and AddComplexType( lSchemaDoc, lRootNode, uAttrSelName, uAttrSel );
  lResult := lResult and AddSchematronForAttrSel( lSchemaDoc, lRootNode, uAttrSel);
  if lResult then Result := lSchemaDoc;
end;


//------------------------------------------------------------------------------
function TBMDPpsXmlValidationGenerator.CreatePpsSchemaDoc(var vSchemaDoc : TBMDXMLDOMDocument; 
var vRootNode: IXMLDOMNode): Boolean;
begin
  if (vSchemaDoc = NIL) and (vRootNode = NIL) then begin
    vSchemaDoc := TBMDXMLDOMDocument.Create(Self);
    vSchemaDoc.SetDocHeader(XML_SCHEMA_VERSION, XML_SCHEMA_ENCODING);
    vRootNode := vSchemaDoc.AddNode(NIL, XML_SCHEMA_ROOTNAME);
    vSchemaDoc.AddNodeAttributes(vRootNode,
                                ['xmlns:xsd', 'targetNamespace', 'xmlns', 'elementFormDefault'],
                                [XML_SCHEMA_XSDNAMESPACE, XML_SCHEMA_PPSNAMESPACE, 
                                XML_SCHEMA_PPSNAMESPACE, XML_SCHEMA_ELEMENTFORM],
                                ''{ANameSpaceURI}, True{ASkipPrefix});
  end;
  Result := Assigned(vSchemaDoc) and Assigned(vRootNode);
end;

//------------------------------------------------------------------------------
// Add a XML-Schematron notation (.xsd) for a specific attribute-selection
//------------------------------------------------------------------------------
function TBMDPpsXmlValidationGenerator.AddSchematronForAttrSel(uDoc:TBMDXMLDOMDocument; 
uParentNode: IXMLDOMNode; uAttrSel: TBMDMDAttrSelection): Boolean;
var lAnnotation,
    lAppInfo   : IXMLDOMNode;
begin
  Result := TRUE;
  if (uAttrSel.AttrGroup.MasterGroup = 60004056) and (uAttrSel.AttrGroup.SubGroup = 7) 
  then begin
    uDoc.AddNodeAttributes(uParentNode, ['xmlns:sch'], [XML_SCHEMATRON_NAMESPACE], 
    ''{ANameSpaceURI}, True{ASkipPrefix});
    lAnnotation := uDoc.AddNode(uParentNode, 'xsd:annotation' {NodeName} );
    lAppInfo := uDoc.AddNode(lAnnotation, 'xsd:appinfo' {NodeName} );
    Result := AddArticleRules( uDoc, lAppInfo );
    if Result then
      DisplayProgress('Saved schematron information correctful');
  end;
end;


//------------------------------------------------------------------------------
// The main node is required in every import/export and is not defined in the selection
//------------------------------------------------------------------------------
function TBMDPpsXmlValidationGenerator.AddMainNode(uDoc: TBMDXMLDOMDocument; uParentNode: 
IXMLDOMNode; uName: string): Boolean;
var
  lMainNode,
  lMainTypeNode,
  lChoiceNode,
  lChildNode: IXMLDOMNode;
begin
  Result := TRUE;
  lMainNode := uDoc.AddNode(uParentNode, 'xsd:element');
  uDoc.AddNodeAttributes(lMainNode, ['name', 'type'], ['MAIN', 'MAIN_TYPE'], '', 
  {ANameSpaceURI} True);

  //add base node for complex type
  lMainTypeNode := uDoc.AddNode(uParentNode, 'xsd:complexType' {NodeName} );
  uDoc.AddNodeAttributes(lMainTypeNode, ['name'], ['MAIN_TYPE'], ''{ANameSpaceURI}, 
  True{ASkipPrefix});
  //add definition-node(choice) for child node
  lChoiceNode := uDoc.AddNode(lMainTypeNode, 'xsd:choice');
  uDoc.AddNodeAttributes(lChoiceNode, ['minOccurs', 'maxOccurs'], ['0', 'unbounded'], 
  ''{ANameSpaceURI}, True{ASkipPrefix});

  lChildNode := uDoc.AddNode(lChoiceNode, 'xsd:element' {NodeName} );
  uDoc.AddNodeAttributes(lChildNode, ['name', 'type'], [uName, uName+'_TYPE'], 
  ''{ANameSpaceURI},   True{ASkipPrefix});
end;

//------------------------------------------------------------------------------
// Adds a new complex-type element in the XML-Schema file
//------------------------------------------------------------------------------
function TBMDPpsXmlValidationGenerator.AddComplexType( uDoc: TBMDXMLDOMDocument; 
uParentNode: IXMLDOMNode; uName : String; uAttrSel: TBMDMDAttrSelection ): Boolean;
var lAttribute : TBMDAttribute;
    lComplexNode,
    lChoiceNode,
    lSimpleNode: IXMLDOMNode;
    lExpAttrSel: TBMDMDAttrSelection;
begin
  Result := TRUE;
  //add base node for complex type
  lComplexNode := uDoc.AddNode(uParentNode, 'xsd:complexType' {NodeName} );
  uDoc.AddNodeAttributes(lComplexNode, ['name'], [uName+'_TYPE'], ''{ANameSpaceURI}, 
  True{ASkipPrefix});
  //add definition-node(choice) for subnodes
  lChoiceNode := uDoc.AddNode(lComplexNode, 'xsd:choice');
  uDoc.AddNodeAttributes(lChoiceNode, ['minOccurs', 'maxOccurs'], ['0', 'unbounded'], 
  ''{ANameSpaceURI}, True{ASkipPrefix});

  if Assigned(uAttrSel.AttributeList) then begin
    for lAttribute in uAttrSel.AttributeList.Attrs do begin
      lExpAttrSel := FXmlMd.AttrSelByNameAndId(uName, lAttribute.ConstId);
      if Assigned(lExpAttrSel) then begin
        if not ImportMode then begin
          //Create new complex node for sub attr selection
          lSimpleNode := uDoc.AddNode(lChoiceNode, 'xsd:element' {NodeName} );
          uDoc.AddNodeAttributes(lSimpleNode, ['name', 'type'], 
          [lExpAttrSel.AttrGroupObj.UserDefinedCaptionMember, 
          lExpAttrSel.AttrGroupObj.UserDefinedCaptionMember+'_TYPE'], 
          ''{ANameSpaceURI}, True{ASkipPrefix});
          Result := AddComplexType(uDoc, uParentNode, 
          lExpAttrSel.AttrGroupObj.UserDefinedCaptionMember, lExpAttrSel);
        end;
      end else begin
        //Add all possible subnodes according to attr-sel
        lSimpleNode := uDoc.AddNode(lChoiceNode {AParentNode}, 
        'xsd:element'{NodeName});
        uDoc.AddNodeAttributes(lSimpleNode, ['name', 'type', 'minOccurs'], 
        [lAttribute.ListCaption, GetElementTypFromAttribute(lAttribute), '0'], 
        ''{ANameSpaceURI}, True{ASkipPrefix});
      end;
    end;
  end;

  // Allow all other nodes (possible need for third companies)
  // would need version 1.1 and is currently not supported in bmd
//  lSimpleNode := uDoc.AddNode(lChoiceNode {AParentNode}, 'xsd:any'{NodeName});
//  uDoc.AddNodeAttributes(lSimpleNode,['minOccurs'],['0'],''{ANameSpaceURI},True{ASkipPrefix});

  // Allow all attributes on node (possible need for third companies) - has to be last
  // would need version 1.1 and is currently not supported in bmd
//  uDoc.AddNode(lComplexNode {AParentNode}, 'xsd:anyAttribute'{NodeName});
                                                                     
  if ImportMode then begin
    Result := Result and AddDefinedSubNodes(uDoc, lChoiceNode, uParentNode, uName);
    Result := Result and AddSpecificAttributes(uDoc, lComplexNode, uAttrSel);
  end;
end;

//------------------------------------------------------------------------------
// Implement specific node attribute that are specified according to CAM-Interface documentation
//------------------------------------------------------------------------------
function TBMDPpsXmlValidationGenerator.AddSpecificAttributes( uDoc: TBMDXMLDOMDocument; 
uParentNode: IXMLDOMNode; uAttrSel: TBMDMDAttrSelection ): Boolean;
begin
  Result := TRUE;
  if (uAttrSel.AttrGroup.MasterGroup = 60004056) and (uAttrSel.AttrGroup.SubGroup = 7) then begin
    AddArticleAttributes( uDoc, uParentNode );
  end;
end;

//------------------------------------------------------------------------------
// All specified attributes for ARTICLE_NODE
//------------------------------------------------------------------------------
procedure TBMDPpsXmlValidationGenerator.AddArticleAttributes( uDoc: TBMDXMLDOMDocument; 
uParentNode: IXMLDOMNode );
var lAttributeNode,
    lRestrictionNode,
    lSimpleNode,
    lPatternNode : IXMLDOMNode;
begin
  //ACTION
  lAttributeNode := uDoc.AddNode(uParentNode {AParentNode}, 'xsd:attribute'{NodeName});
  uDoc.AddNodeAttributes(lAttributeNode, ['name', 'use'], ['ACTION', 'required'], 
  ''{ANameSpaceURI}, True{ASkipPrefix});
  lSimpleNode := uDoc.AddNode(lAttributeNode {AParentNode}, 'xsd:simpleType'{NodeName});
  lRestrictionNode := uDoc.AddNode(lSimpleNode {AParentNode}, 'xsd:restriction'{NodeName});
  uDoc.AddNodeAttributes(lRestrictionNode, ['base'], ['xsd:string'], ''{ANameSpaceURI}, 
  True{ASkipPrefix});
  lPatternNode := uDoc.AddNode(lRestrictionNode {AParentNode}, 'xsd:pattern'{NodeName});
  uDoc.AddNodeAttributes(lPatternNode, ['value'], ['NEW|CREATE|MODIFY|DELETE'], 
  ''{ANameSpaceURI}, True{ASkipPrefix});
  //GENERATE_ARTICLENO
  lAttributeNode := uDoc.AddNode(uParentNode {AParentNode}, 'xsd:attribute'{NodeName});
  uDoc.AddNodeAttributes(lAttributeNode, ['name', 'type'], ['GENERATE_ARTICLENO', 
  'xsd:boolean'], ''{ANameSpaceURI}, True{ASkipPrefix});
  //COPY_PIECELIST
  lAttributeNode := uDoc.AddNode(uParentNode {AParentNode}, 'xsd:attribute'{NodeName});
  uDoc.AddNodeAttributes(lAttributeNode, ['name', 'type'], ['COPY_PIECELIST', 
  'xsd:boolean'], ''{ANameSpaceURI}, True{ASkipPrefix});
  //COPY_SUPPLIER_REGISTRY
  lAttributeNode := uDoc.AddNode(uParentNode {AParentNode}, 'xsd:attribute'{NodeName});
  uDoc.AddNodeAttributes(lAttributeNode, ['name', 'type'], ['COPY_SUPPLIER_REGISTRY', 
  'xsd:boolean'], ''{ANameSpaceURI}, True{ASkipPrefix});
  //COPY_ARTICLE
  lAttributeNode := uDoc.AddNode(uParentNode {AParentNode}, 'xsd:attribute'{NodeName});
  uDoc.AddNodeAttributes(lAttributeNode, ['name', 'type'], ['COPY_ARTICLE', 'xsd:string'], 
  ''{ANameSpaceURI}, True{ASkipPrefix});
end;

//------------------------------------------------------------------------------
// Converts an BMD-Attribute (an element which respresents a XML-Attribute or XML-Element)
//  to the according XML-Typ
//------------------------------------------------------------------------------
function TBMDPpsXmlValidationGenerator.AddDefinedSubNodes(uDoc: TBMDXMLDOMDocument; 
uParentNode, uTypeParentNode: IXMLDOMNode; uAttrSelName: string): Boolean;
var
  lObj : TBMDWWSPPSProcessRegObj;
  lAllowedSubNode: String;
  i : Integer;
  lSimpleNode : IXMLDOMNode;
begin
  Result := TRUE;
  lObj := TBMDWWSPPSProcessRegObj( 
  FXmlMd.GetRegAttrSelections4Import.ObjByString[ uAttrSelName ] );
  for lAllowedSubNode in lObj.AllowedSubNodes do begin
    if Result and FXmlMd.GetRegAttrSelections4Import.Find(lAllowedSubNode, i) then begin
      lSimpleNode := uDoc.AddNode(uParentNode, 'xsd:element' {NodeName} );
      uDoc.AddNodeAttributes(lSimpleNode, ['name', 'type'], [lAllowedSubNode, 
      lAllowedSubNode+'_TYPE'], ''{ANameSpaceURI}, True{ASkipPrefix});
      Result := AddComplexType( uDoc, uTypeParentNode, lAllowedSubNode, 
      FXmlMd.AttrSelByNodeName(lAllowedSubNode) );
    end;
  end;      
end;

//------------------------------------------------------------------------------
// Converts an BMD-Attribute (an element which respresents a XML-Attribute or XML-Element)
//  to the according XML-Typ
//------------------------------------------------------------------------------
function TBMDPpsXmlValidationGenerator.GetElementTypFromAttribute( uAttribute: 
TBMDAttribute ): String;
begin
  case uAttribute.DataType of
    adtString  : Result := 'xsd:string';
    adtBoolean : Result := 'xsd:boolean';
    adtNumber  : Result := 'xsd:decimal';
    adtDate    : Result := 'xsd:dateTime';
  end;
end;

//------------------------------------------------------------------------------
// Generates a XML-Schematron file for the Article-Import/Export
//------------------------------------------------------------------------------
function TBMDPpsXmlValidationGenerator.AddArticleRules( uDoc: TBMDXMLDOMDocument; 
uParentNode: IXMLDOMNode ): Boolean;
var lPatternNode,
    lRuleNode : IXMLDOMNode;
begin
  Result := TRUE;
  lPatternNode := AddPattern(uDoc, uParentNode, 'Check ArtikelNr');
  lRuleNode := AddRule(uDoc, lPatternNode, 'ARTICLE[@GENERATE_ARTICLENO=TRUE]');
  AddAssertion(uDoc, lRuleNode, 'boolean(./ARTICLE_NO/text())', 'Wenn Attribut 
  GENERATE_ARTICLENO=TRUE ist, darf keine ArtikelNr gesetzt sein');

end;

//------------------------------------------------------------------------------
// Adds a new pattern element in the XML-Schematron file
//------------------------------------------------------------------------------
function TBMDPpsXmlValidationGenerator.AddPattern( uDoc: TBMDXMLDOMDocument; 
uParentNode: IXMLDOMNode; uName : String ): IXMLDOMNode;
var lPatternNode : IXMLDOMNode;
begin
  lPatternNode := uDoc.AddNode(uParentNode, 'sch:pattern' {NodeName}, ['name'], [uName]);
  Result := lPatternNode;
end;

//------------------------------------------------------------------------------
// Adds a new rule element in the XML-Schematron file
//------------------------------------------------------------------------------
function TBMDPpsXmlValidationGenerator.AddRule( uDoc: TBMDXMLDOMDocument; 
uParentNode: IXMLDOMNode; uContext : String ): IXMLDOMNode;
var lRuleNode : IXMLDOMNode;
begin
  lRuleNode := uDoc.AddNode(uParentNode, 'sch:pattern' {NodeName}, ['context'],
  [uContext]);
  Result := lRuleNode;
end;

//------------------------------------------------------------------------------
// Adds a new assertion element in the XML-Schematron file
//------------------------------------------------------------------------------
function TBMDPpsXmlValidationGenerator.AddAssertion( uDoc: TBMDXMLDOMDocument; 
uParentNode: IXMLDOMNode; uTest, uMessage : String ): IXMLDOMNode;
var lAssertionNode : IXMLDOMNode;
begin
  lAssertionNode := uDoc.AddNode(uParentNode, 'sch:assert' {NodeName}, 
  uMessage {Text}, ['test'], [uTest]);
  Result := lAssertionNode;
end;            

//------------------------------------------------------------------------------
// Returns the error property, for occured errors (logs)
//------------------------------------------------------------------------------
function TBMDPpsXmlValidationGenerator.GetError: String;
begin
  Result := FError;
end;

//------------------------------------------------------------------------------
// Sets the error property, for occured errors (logs)
//------------------------------------------------------------------------------
procedure TBMDPpsXmlValidationGenerator.SetError(uValue: String);
begin
  FError := uValue;
end;

//------------------------------------------------------------------------------
// Returns the status property, for http communication
//------------------------------------------------------------------------------
function TBMDPpsXmlValidationGenerator.GetStatus: String;
begin
  Result := FStatus;
end;

//------------------------------------------------------------------------------
// Sets the status property, for http communication
//------------------------------------------------------------------------------
procedure TBMDPpsXmlValidationGenerator.SetStatus(uValue: String);
begin
  FStatus := uValue;
end;

//------------------------------------------------------------------------------
// Returns the event method, for communication
//------------------------------------------------------------------------------
function TBMDPpsXmlValidationGenerator.GetDoDisplay: TBMDDoDisplayAbortEvent;
begin
  Result := FDoDisplay;
end;

//------------------------------------------------------------------------------
// Sets the event method, for communication
//------------------------------------------------------------------------------
procedure TBMDPpsXmlValidationGenerator.SetDoDisplay(uEvent: TBMDDoDisplayAbortEvent);
begin
  FDoDisplay := uEvent;
end;


//------------------------------------------------------------------------------
// Returns if schema is generated for import or export
//------------------------------------------------------------------------------
function TBMDPpsXmlValidationGenerator.GetImportMode: Boolean;
begin
  Result := FImportMode;
end;

//------------------------------------------------------------------------------
// Sets the importMode property, determines if schema is generated for import or export
//------------------------------------------------------------------------------
procedure TBMDPpsXmlValidationGenerator.SetImportMode(uValue: Boolean);
begin
  FImportMode := uValue;
end;

//------------------------------------------------------------------------------
// Communication method, to display messages in the program
//------------------------------------------------------------------------------
function TBMDPpsXmlValidationGenerator.DisplayProgress(uDisplay: String): Boolean;
begin
  if Assigned(FDoDisplay) then begin
    Result := FDoDisplay(uDisplay);
  end
  else begin
    Result := TRUE;
  end;
end;

initialization
begin
  TheClassFactory().AddClass(MC_MDPPS_XMLVALIDATION, TBMDPpsXmlValidationGenerator);
end;



end.