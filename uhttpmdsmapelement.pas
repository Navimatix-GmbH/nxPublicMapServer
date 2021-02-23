unit uhttpmdsmapelement;
// als erstes implementieren: TNxMapRoadElement und TNaMROServicePoint
interface

uses types, classes, SysUtils, XMLIntf, XMLDoc, TypInfo,
  uhttpmdsbase, uhttpmdsmapelementbase, uhttpmdsgeocoding;

const
  // Unterstützte Funktionen
  WMCMD_GETMAPELEMENT                     = '/getmapelement';
  WMCMD_FINDNEARESTMAPELEMENTS            = '/findnearestmapelements';
  WMCMD_RANGEQUERYMAPELEMENTS             = '/rangequerymapelements';

type

  TMapElementType = (
    T_UNDEFINED,
    T_ROADELEMENT, T_ROADELEMENTJUNCTION, T_INTERSECTION,
    T_STREET, T_STREETCOLLECTION, T_ADMINISTRATIVEINFO, T_SERVICEPOINT,
    T_AREA, T_RAILWAYELEMENT, T_BASICLINE, T_PARCEL,
    T_ROBTNAME,
    T_ROTROSTMETAINFO  );

  TGeometryType = (
    T_GEOMETRYUNDEFINED, T_GEOMETRYPOINT,
    T_GEOMETRYLINE, T_GEOMETRYAREA
  );

  TAdminOrder =
    (NaMMPAO_COUNTRY, NaMMPAO_COUNTRYPART,
     NaMMPAO_COUNTRYDISTRICT, NaMMPAO_CITY,
     NaMMPAO_CITYPART, NaMMPAO_BUILDINGCOMPLEX);

  TNnxMapElement = Class(THTTPConnectorResult)
  protected
    fElementType            : TMapElementType;
    fMapCID                 : Integer;
    fMapID                  : String;
    fRO, fROT, fROST        : Cardinal;
  public
    constructor Create(CopyStreamOnLoad : Boolean = false); override;
    destructor Destroy; override;

    class function createFromXML(aMapElementNode: IXmlNode): TNnxMapElement;
    class function createFromStream(aFromStream : TStream): TNnxMapElement;
    class function createInstanceFromType(aTypeIdent : String): TNnxMapElement;

    procedure internalLoadFromStream; override;

    procedure loadFromXML(aMapElementNode: IXmlNode); virtual;

    class function StrToRoadElementType(aRoadElemType: String):TRoadType;
    class function StrToFunctionalRoadClass(aRoadClass: String): TFunctionalRoadClass;
    class function StrToFormOfWay(aFormOfWay: String): TFormOfWay;
    class function StrToBlockedPassage(aBlockedPassage: String):TBlockedPassage;
    class function StrTotMainDirectionFlow(aMainDirectionFlow: String):TMainDirectionFlow;
    class function StrToConstructionState(aConstructionState: String): TConstructionState;

    property ElementType : TMapElementType read fElementType write fElementType;
    property ROId : Cardinal read fro write fro;
    property ROTId: Cardinal read frot write frot;
    property ROSTId: Cardinal read frost write frost;
  end;

  TGeometry = class
    fType        : TGeometryType; // Point/ Line / Area
    fPositions   : THTTPMDSList;
  protected
    procedure loadfromXML(aBaseNode : IXMLNode); virtual;

    constructor Create; virtual;
    destructor Destroy; override;
  public
  end;

  TNxMapPoint = class(TGeometry)
    private
      fLongitude  : double;
      fLatitude   : double;
    protected
      constructor Create; virtual;
      destructor Destroy; override;

      procedure loadfromxml(aposnode: IXMLNode);
      class function createfromxml(aposnode: IXMLNode): TNxMapPoint;
    public

  end;

  TNxMapLine = class(TGeometry)
    private
      fpositions: THTTPMDSList; // of TNxMapPoint
    public
      constructor Create; override;
      destructor Destroy; override;

      property Positions: THTTPMDSList read fpositions write fpositions;
      procedure loadfromxml(aGeometrynode: IXMLNode);
      class function createfromxml(aLinenode: IXMLNode): TNxMapLine;
  end;

  TNxMapArea=  class(TGeometry)
    private
      fpositions: THTTPMDSList; // of TNxMapPoint
    public
      constructor Create; virtual;
      destructor Destroy; override;
  end;


  TNxMapRoadElement= class(TNnxMapElement)
  private
    fElementID           : Cardinal;
    fElementType         : TRoadType;
    fFunctionalRoadClass : TFunctionalRoadClass;
    fThroughTraffic      : Boolean;
    fFormOfWay           : TFormOfWay;
    fBlockedPassage      : TBlockedPassage;
    fMainDirectionFlow   : TMainDirectionFlow;
    fLength              : Cardinal;
    fConstructionState   : TConstructionState;
    fMaxSpeed            : Byte;
    fAverageSpeed        : Byte;
    fStartJunctionID     : Cardinal;
    fEndJunctionID       : Cardinal;
    fOfficialNameID      : Cardinal;
    fOfficialName        : string;
    fRouteNumberID       : Cardinal;
    fRouteNumber         : string;
    fGeometry            : TGeometry;
    fAttributes          : THTTPMDSList;
  protected
    procedure internalLoadFromStream; override;   //überschreibt internalLoadFromStream des THTTPConnectorResult
    procedure loadfromXML(aMapElementNode : IXMLNode); override;
  public
    constructor Create(CopyStreamOnLoad : Boolean = false); override;
    destructor Destroy; override;
  end;

  TAttribute = class  // Description of a single attribute
  protected
    fId           : Cardinal;
    fType         : Cardinal;
    fTypeString   : String;
    fValue        : Cardinal;
    fValueString  : String;
  protected
    procedure loadfromXML(aBaseNode : IXMLNode); virtual;
  public
    constructor Create; reintroduce; virtual;
    destructor Destroy; override;
    property Id              : Cardinal read fId;
    property AttType         : Cardinal read fType;
    property AttTypeString   : String read fTypeString;
    property AttValue        : Cardinal read fValue;
    property AttValueString  : String read fValueString;
  end;


  // Types für TNaMRORoadElementJunction
  TNXMapRoadJunctionType = (
    TNXMapRoad_RJT_Unknown,
    TNXMapRoad_RJT_MiniRoundabout,   // Die Junction selbst ist ein kleiner, nicht modellierter Kreisverkehr...
    TNXMapRoad_RJT_PartOfRoundabout, // Einfahrt oder Ausfahrt eines komplex modellierten Kreisverkehres...
    TNXMapRoad_RJT_Bifurcation,      // Gabelung
    TNXMapRoad_RJT_RailwayCrossing,
    TNXMapRoad_RJT_BorderCrossing);

  // Types für TNaMROArea
  TNXMapFunctionalAreaType = (MSROPD_FAT_NONE, MSROPD_FAT_0, MSROPD_FAT_1);

  // Types für TNaMRORoadIntersection
  TNXMapRoadIntersectionType = (TNXMap_RIT_FreewayIntersection,
    TNXMap_RIT_Roundabout,  TNXMap_RIT_Crossing, TNXMap_RIT_None);

  TNxMapRoadElementJunction= class(TNnxMapElement)
  private
    fJunctionType        : TNXMapRoadJunctionType;
    fMiddlePointID       : Cardinal;
    fMiddlePoint         : TGeoCoderPosition;
    fRoadElementIDCount  : Cardinal;
    fRoadElementCount    : Cardinal;
    fRoadElementIDs      : THTTPMDSList; // Array of Cardinal;
    fGeometry            : THTTPMDSList; // Points
    fAttributes          : THTTPMDSList;
  protected
    constructor Create; virtual;
    destructor Destroy; override;
    procedure loadfromXML(aRoadElementJunctionNode : IXMLNode);
    class function StrToJunctionType(aJunctionType: String): TNXMapRoadJunctionType;
  end;

  TNxMapIntersection= class(TNnxMapElement)
  private
    fIntersectionType : TNXMapRoadIntersectionType;
    fMiddlePointID    : Cardinal;
    fOfficialNameID   : Cardinal;
    fOfficialName     : String;
    fElementIDCount   : Integer;
    fRoadElements     : THTTPMDSList; // Array of TNxMapRoadElement;
    fAttributes       : THTTPMDSList;
  protected
     // procedure loadfromXML(aIntersectionNode : IXMLNode): Boolean;
  public
    constructor Ceate; virtual;
    destructor Destroy; override;
  end;

  TNnxMapStreet= class(TNnxMapElement)
    private
      fOfficialNameID      : Cardinal;
      fOfficialName        : String;
      fZipCodeID           : Cardinal;
      fZipCode             : String;
      fAdministrativeInfoID: Cardinal;
      fRoadElementCount    : Integer;
      fRoadElementIDs      : THTTPMDSList; // Cardinal values
    protected
     // procedure loadfromXML(aStreetNode : IXMLNode): Boolean;
    public
      constructor Create; virtual;
      destructor Destroy;  override;
  end;

  TNnxMapStreetCollection = class(TNnxMapElement)
    private
      fAdministrativeInfoID: Cardinal;
      fStreetIDCount       : Integer;
      fStreetIDs           : THTTPMDSList;  // Cardinal values
    protected
     // procedure loadfromXML(aStreetCollectionNode : IXMLNode): Boolean;
    public
      constructor Create; virtual;
      destructor Destroy; override;
  end;

  TNnxMapArea = class(TNnxMapElement)
    private

    protected

    public
      constructor Create; virtual;
      destructor Destroy; override;
  end;

  TNnxMapServicePoint= class(TNnxMapElement)
  private
    fFunctionalClass  : Byte;
    fMiddlePointID    : Cardinal;
    fBelongsToAdminID : Cardinal;
    fOfficialNameID   : Cardinal;
    fOfficialName     : String;
    fMiddlePoint      : TNxMapPoint;
  protected
    procedure loadfromXML(aServicePointNode : IXMLNode);  override;
  public
    constructor Create(CopyStreamOnLoad : Boolean = false); override;
    destructor Destroy; override;
  end;

  TNnxMapElementList = class(THTTPConnectorResult)
  private
    fMapElements: TList;
    fmapcid     : Integer;
    fmapid      : String;
  public
    constructor Create(CopyStreamOnLoad : Boolean = false); override;
    destructor Destroy; override;

    property MapElements: TList read fMapElements write fMapElements;
    class function createFromStream(aFromStream : TStream): TNnxMapElementList;
  end;

  THTTPMDSMapElementAccess = class(TComponent)
  private
    fHTTP                 : THTTPConnector;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // Für jedes Kommando (Request an Mapserver) existiert hier eine eigene function
    function getMapElement(amapcontextID: Integer; arot, aro, arost: Cardinal): TNnxMapElement;
    function findNearestMapElements(arot, arost: Cardinal; aLong, aLat: double; aRadius: double): TNnxMapElementList;
    function rangequerymapelements(amapcid: integer; arot, arost: Cardinal; ageoleft, ageotop, ageoright, ageobottom: double): TNnxMapElementList;
    // Reply: mapobjects/element jeweils mit typedata, geometry
    // Test- URL: http://npc049:8086/rangequerymapelements?rot=20&rost=1&geoleft=11.07&geotop=50.700001&georight=11.070001&geobottom=50.7&mapcid=0
    // liefert TNaMRORoadElements (wegen Parametern rot=20 (ROTID_ROADS) und rost=1 (ROSTID_ROADELEMENTS))
    // Weitere Test- URL:
    // http://nsrv57:8086/rangequerymapelements?rot=40&rost=0&geoleft=11.04&geotop=50.9&georight=11.09&geobottom=50.6&mapcid=-1
  published
    property HTTP : THTTPConnector read fHTTP write fHTTP;
  end;


implementation

uses Math;

{ **************************************************************************** }
{ ***** Allgemeine Funktionen ************************************************ }
{ **************************************************************************** }
var MapServerFS : TFormatSettings;

procedure initXMLSchemaDataTypesV2FormatSettings(var FormatSettings : TFormatSettings);
begin
  with FormatSettings do
  begin
    CurrencyFormat:=3;
    NegCurrFormat:=8;
    ThousandSeparator:=' ';
    DecimalSeparator:='.';
    CurrencyDecimals:=2;
    DateSeparator:='-';
    TimeSeparator:=':';
    ListSeparator:=';';
    CurrencyString:='€';
    //ShortDateFormat:='dd.MM.yyyy';
    ShortDateFormat:='yyyy-MM-dd';
    //LongDateFormat:='dddd, d. MMMM yyyy';
    //eigentlich : ''-''? yyyy ''-'' mm ''-'' zzzzz ?, aber Z = UTC
    LongDateFormat:='dddd, MMMM d. yyyy';
    TimeAMString:='';
    TimePMString:='';
    ShortTimeFormat:='hh:mm';
    LongTimeFormat:='hh:mm:ss';
    ShortMonthNames[1]:='Jan';
    ShortMonthNames[2]:='Feb';
    ShortMonthNames[3]:='Mrz';
    ShortMonthNames[4]:='Apr';
    ShortMonthNames[5]:='Mai';
    ShortMonthNames[6]:='Jun';
    ShortMonthNames[7]:='Jul';
    ShortMonthNames[8]:='Aug';
    ShortMonthNames[9]:='Sep';
    ShortMonthNames[10]:='Okt';
    ShortMonthNames[11]:='Nov';
    ShortMonthNames[12]:='Dez';
    LongMonthNames[1]:='Januar';
    LongMonthNames[2]:='Februar';
    LongMonthNames[3]:='März';
    LongMonthNames[4]:='April';
    LongMonthNames[5]:='Mai';
    LongMonthNames[6]:='Juni';
    LongMonthNames[7]:='Juli';
    LongMonthNames[8]:='August';
    LongMonthNames[9]:='September';
    LongMonthNames[10]:='Oktober';
    LongMonthNames[11]:='November';
    LongMonthNames[12]:='Dezember';
    ShortDayNames[1]:='So';
    ShortDayNames[2]:='Mo';
    ShortDayNames[3]:='Di';
    ShortDayNames[4]:='Mi';
    ShortDayNames[5]:='Do';
    ShortDayNames[6]:='Fr';
    ShortDayNames[7]:='Sa';
    LongDayNames[1]:='Sonntag';
    LongDayNames[2]:='Montag';
    LongDayNames[3]:='Dienstag';
    LongDayNames[4]:='Mittwoch';
    LongDayNames[5]:='Donnerstag';
    LongDayNames[6]:='Freitag';
    LongDayNames[7]:='Samstag';
    TwoDigitYearCenturyWindow:=0;
  end;
end;

{ **************************************************************************** }
{ ***** TAttribute *********************************************************** }
{ **************************************************************************** }
constructor TAttribute.Create;
begin
  inherited;
end;

destructor  TAttribute.Destroy;
begin
  inherited;
end;

procedure TAttribute.loadfromxml(aBaseNode : IXMLNode);
var aktNode: IXMLNode;
begin
  if (aBaseNode <> nil) then
  begin
    if aBaseNode.HasAttribute('id') then
    begin
      fId := StrToIntDef(aBaseNode.Attributes['id'], 0);
      aktNode := aBaseNode.ChildNodes.FindNode('type');
      if aktNode <> nil then
      begin
        fType  := StrToIntDef(aktNode.Attributes['value'], 0);
        fTypeString := aktNode.Text;
      end;
      aktNode := aBaseNode.ChildNodes.FindNode('value');
      if aktNode <> nil then
      begin
        fValue  := StrToIntDef(aktNode.Attributes['value'], 0);
        fValueString := aktNode.Text;
      end;
    end;
  end;
end;

{ **************************************************************************** }
{ ***** TNxMapPoint ********************************************************** }
{ **************************************************************************** }
constructor TNxMapPoint.Create;
begin
  inherited Create;
  fType:= T_GEOMETRYPOINT;
end;

destructor TNxMapPoint.Destroy;
begin
  inherited;
end;

class function TNxMapPoint.createfromxml(aPosnode: IXMLNode): TNxMapPoint;
begin
  if aposnode <> nil then
  begin
    result:= TNxMapPoint.create;
    result.loadfromxml(aposnode);
  end
  else begin
    raise Exception.Create('TNxMapPoint.loadfromxml: aposnode is nil');
  end;
end;

procedure TNxMapPoint.loadfromxml(aposnode: IXMLNode);
var clon, clat : string;
begin
  if aposnode <> nil then
  begin
    // aposnode.NodeName= 'position' wird nicht ausgewertet
    if aposnode.HasAttribute('lon') then
    begin
      clon := aposnode.Attributes['lon'];
      fLongitude := StrToFloatDef(clon, nan, MapServerFS);
    end;
    if aposnode.HasAttribute('lat') then
    begin
      clat := aposnode.Attributes['lat'];
      fLatitude := StrToFloatDef(clat, nan, MapServerFS);
    end;
  end else
  begin
    raise Exception.Create('TNxMapPoint.loadfromxml: aposnode is nil');
  end;
end;

{ **************************************************************************** }
{ ***** TNxMapLine *********************************************************** }
{ **************************************************************************** }
constructor TNxMapLine.Create;
begin
  inherited Create;
  fpositions:= THTTPMDSList.Create;
  fType:= T_GEOMETRYLINE;
end;

destructor TNxMapLine.Destroy;
begin
  FreeAndNil(fpositions);
  inherited;
end;

class function TNxMapLine.createfromxml(aLinenode: IXMLNode): TNxMapLine;
begin
  if aLinenode <> nil then
  begin
    result:= TNxMapLine.Create;
    result.loadfromxml(aLinenode);
  end
  else begin
    raise Exception.Create('TNxMapLine.createfromxml: aLinenode is nil');
  end;
end;

procedure TNxMapLine.loadfromxml(aGeometrynode : IXMLNode);
var clon, clat : string;
  i: Integer;
  fpos: TNxMapPoint;
  aNode: IXmlNode;
begin
  // aGeometrynode.attributes['primitive]="line"'
  if aGeometrynode <> nil then
  begin
    for i:=  0 to aGeometrynode.ChildNodes.Count - 1 do
    begin
       fpos:= TNxMapPoint.create;
       aNode:= aGeometrynode.ChildNodes.Get(i);
       fpos.createfromxml(aNode);
       fpositions.Add(fpos);
    end;
  end else
  begin
    raise Exception.Create('TNxMapLine.loadfromxml: aLinenode is nil');
  end;
end;

{ **************************************************************************** }
{ ***** TNxMapArea *********************************************************** }
{ **************************************************************************** }
Constructor TNxMapArea.Create;
begin
  inherited;
  fpositions:= THTTPMDSList.Create;
end;

Destructor TNxMapArea.destroy;
begin
  FreeAndNil(fpositions);
  inherited;
end;

{ **************************************************************************** }
{ ***** TGeometry ************************************************************ }
{ **************************************************************************** }
constructor TGeometry.create;
begin
  inherited;
  fPositions:= THTTPMDSList.Create;
end;

destructor TGeometry.destroy;
begin
  FreeAndNil(fPositions);
  inherited;
end;

procedure TGeometry.loadfromXML(aBaseNode : IXMLNode);
// aBaseNode= 'geometry'
var
  i: Integer;
  zs: String;
  aktNode: IXMLNode;
  cPosType: TGeometryType;
  cPoint: TNxMapPoint;
  cLine : TNxMapLine;
  cArea : TNxMapArea;
begin
  if aBaseNode.NodeName= ('geometry') then
  begin
    if not aBaseNode.HasAttribute('primitive') then exit;
    cPosType:= T_GEOMETRYUNDEFINED;
    zs:= 'T_GEOMETRY' + UpperCase(aBaseNode.Attributes['primitive']);
    // cPosType= Point/ Line / Area
    cPosType:= TGeometryType(GetEnumValue(System.TypeInfo(TGeometryType), zs));

    case cPosType of
       T_GEOMETRYLINE:
         begin
           cLine:= TNxMapLine.create;
           for i:= 0 to aBaseNode.ChildNodes.Count - 1 do
           begin
             aktNode:= aBaseNode.ChildNodes.get(i);
             cPoint.createfromxml(aktNode);
             cLine.Positions.Add(cPoint);
           end;
           fPositions:= cLine.Positions;
         end;
         T_GEOMETRYPOINT:
         begin  //  nicht getestet!
           cPoint:= TNxMapPoint.create;
           aktNode:= aBaseNode.ChildNodes.FindNode('position');
           cPoint.loadfromxml(aktNode);
           fPositions.Add(cPoint);
         end;
         T_GEOMETRYAREA:
         begin  //  nicht getestet!
           cArea:= TNxMapArea.create;
           aktNode:= aBaseNode.ChildNodes.FindNode('position');  // NodeName prüfen!
           cArea.loadfromxml(aktNode);
         end;
      end;
  end; // if
end;

{ **************************************************************************** }
{ ***** TNxMapRoadElement **************************************************** }
{ **************************************************************************** }
constructor TNxMapRoadElement.Create(CopyStreamOnLoad : Boolean = false);
begin
  inherited create(CopyStreamOnLoad);
  fElementID           := 0;
  fElementType         := RT_UNKNOWN;
  fFunctionalRoadClass := FRC00;
  fThroughTraffic      := False;
  fFormOfWay           := FOW_Unknown;
  fBlockedPassage      := BP_None;
  fMainDirectionFlow   := DF_Unknown;
  fLength              := 0;
  fConstructionState   := CS_UNKNOWN;
  fMaxSpeed            := 0;
  fAverageSpeed        := 0;
  fStartJunctionID     := 0;
  fEndJunctionID       := 0;
  fOfficialNameID      := 0;
  fOfficialName        := '';
  fRouteNumberID       := 0;
  fRouteNumber         := '';
end;

destructor TNxMapRoadElement.Destroy;
begin
  inherited;
end;

procedure TNxMapRoadElement.internalLoadFromStream;
begin
 // todo: implement me...
 // Im Stream ist das gesamte Reply- xml enthalten.
 // Das einzelne TNxMapRoadElement wird geparst mit loadfromXML;
end;

procedure TNxMapRoadElement.loadfromXML(aMapElementNode : IXMLNode);
var
  aktNode, typeDataNode,
  geometryNode  : IXMLNode;
  fPos          : TGeoCoderPosition;
  flon, flat    : Double;
  fgeometryType : String;
  i,
  cgeometryPositionsCount             : integer;
begin
  // aMapElemNode ist <mapelement type="...">
  inherited loadFromXML(aMapElementNode);  // --> TNnxMapElement.loadFromXML

  typedataNode:= aMapElementNode.ChildNodes.FindNode('typedata');
  aktNode:= typedataNode.ChildNodes.FindNode('ElementType');
  fElementType:= StrToRoadElementType(aktNode.Text);
  aktNode:= typedataNode.ChildNodes.FindNode('FunctionalRoadClass');
  if (aktNode<> nil) then fFunctionalRoadClass:= StrToFunctionalRoadClass(aktNode.Text);
  aktNode:= typeDataNode.ChildNodes.FindNode('ThroughTraffic');
  if (aktNode<> nil) then fThroughTraffic:= StrToBool(aktNode.Text);
  aktNode:= typeDataNode.ChildNodes.FindNode('FormOfWay');
  if (aktNode<> nil) then fFormOfWay:= StrToFormOfWay(aktNode.Text);
  aktNode:= typeDataNode.ChildNodes.FindNode('BlockedPassage');
  if (aktNode<> nil) then fBlockedPassage:= StrToBlockedPassage(aktNode.Text);
  aktNode:= typeDataNode.ChildNodes.FindNode('MainDirectionFlow');
  if (aktNode<> nil) then fMainDirectionFlow:= StrTotMainDirectionFlow(aktNode.Text);
  aktNode:= typeDataNode.ChildNodes.FindNode('Length');
  if (aktNode<> nil) then fLength:= aktNode.NodeValue;
  aktNode:= typeDataNode.ChildNodes.FindNode('ConstructionState');
  if (aktNode<> nil) then fConstructionState:= StrToConstructionState(aktNode.Text);
  aktNode:= typeDataNode.ChildNodes.FindNode('MaxSpeed');
  if (aktNode<> nil) then
  begin
    if(aktNode.Text)<> '' then fMaxSpeed:= aktNode.NodeValue else fMaxSpeed:= 0;
  end;
  aktNode:= typeDataNode.ChildNodes.FindNode('AverageSpeed');
  if (aktNode<> nil) then
  begin
    if (aktNode.Text <> '') then fAverageSpeed:= aktNode.NodeValue else fAverageSpeed:= 0;
  end;
  aktNode:= typeDataNode.ChildNodes.FindNode('StartJunctionID');
  if (aktNode<> nil) then
  begin
    if (aktNode.Text<> '') then fStartJunctionID:= aktNode.NodeValue else fStartJunctionID:= 0;
  end;
  aktNode:= typeDataNode.ChildNodes.FindNode('EndJunctionID');
  if (aktNode<> nil) then
  begin
    if (aktNode.Text <> '') then fEndJunctionID:= aktNode.NodeValue else fEndJunctionID:= 0;
  end;
  aktNode:= typeDataNode.ChildNodes.FindNode('OfficialNameID');
  if (aktNode<> nil) then
  begin
    if (aktNode.Text <> '') then fOfficialNameID:= aktNode.NodeValue else fOfficialNameID:=0;
  end;
  aktNode:= typeDataNode.ChildNodes.FindNode('OfficialName');
  if (aktNode<> nil) then fOfficialName:= aktNode.Text;
  aktNode:= typeDataNode.ChildNodes.FindNode('RouteNumberID');
  if (aktNode<> nil) then fRouteNumberID:= aktNode.NodeValue;
  aktNode:= typeDataNode.ChildNodes.FindNode('RouteNumber');
  if (aktNode<> nil) then fRouteNumber:= aktNode.Text;
  try
    // geometry...
    geometryNode:= aMapElementNode.ChildNodes.FindNode('geometry');
    if geometryNode<> nil then
    begin
      fGeometry:= TGeometry.create;
      fGeometry.loadfromXML(geometryNode);
    end;
  except
    on e : exception do
    begin
      raise;
    end;
  end;
end;

{ **************************************************************************** }
{ ***** TNnxMapServicePoint ************************************************** }
{ **************************************************************************** }
constructor TNnxMapServicePoint.Create(CopyStreamOnLoad : Boolean = false);
begin
  inherited Create(CopyStreamOnLoad);
  fFunctionalClass  := 0;
  fMiddlePointID    := 0;
  fBelongsToAdminID := 0;
  fOfficialNameID   := 0;
  fOfficialName     := '';
  fMiddlePoint      := TNxMapPoint.Create;
end;

destructor TNnxMapServicePoint.Destroy;
begin
  inherited Destroy;
end;

procedure TNnxMapServicePoint.loadfromXML(aServicePointNode : IXMLNode);
var
   aktNode,
   typeDataNode, geometryNode,
   attributesNode, attributeNode: IXMLNode;
   cStr : String;
   iatt : Integer;
   aktAttribute: TAttribute;
begin
  // typedata
  typedataNode:= aServicePointNode.ChildNodes.FindNode('typedata');
  aktNode:= typedataNode.ChildNodes.FindNode('FunctionalClass');
  if (aktNode<> nil) then fFunctionalClass:= aktNode.NodeValue;  // Byte
  aktNode:= typedataNode.ChildNodes.FindNode('MiddlePointID');
  if (aktNode<> nil) then fMiddlePointID:= aktNode.NodeValue;
  aktNode:= typedataNode.ChildNodes.FindNode('BelongsToAdminID');
  if (aktNode<> nil) then fBelongsToAdminID:= aktNode.NodeValue;
  aktNode:= typedataNode.ChildNodes.FindNode('OfficialNameID');
  if (aktNode<> nil) then fOfficialNameID:= aktNode.NodeValue;
  aktNode:= typedataNode.ChildNodes.FindNode('OfficialName');
  if (aktNode<> nil) then fOfficialName:= aktNode.NodeValue;
  geometryNode:= aServicePointNode.ChildNodes.FindNode('geometry');
  if geometryNode.HasAttribute('primitive') then
  begin
     if geometryNode.Attributes['primitive'] = 'point' then
     begin
       fMiddlePoint.loadfromxml(geometryNode.ChildNodes.FindNode('position'));  //parseXMLPosition(geometryNode);    // warum geht parseXMLPosition(aBaseNode : IXMLNode); nicht, wenn es protected deklariert ist?
     end;
  end;
end;

{ **************************************************************************** }
{ ***** TNxMapRoadElementJunction ******************************************** }
{ **************************************************************************** }
constructor TNxMapRoadElementJunction.create;
begin
  inherited Create;
  fJunctionType       := TNXMapRoad_RJT_Unknown;
  fMiddlePointID      := 0;
  fMiddlePoint        := TGeoCoderPosition.Create;
  fRoadElementIDCount := 0;
  fRoadElementCount   := 0;
  fRoadElementIDs     := THTTPMDSList.Create;
  fGeometry           := THTTPMDSList.Create;
end;

destructor TNxMapRoadElementJunction.destroy;
begin
  FreeAndNil(fRoadElementIDs);
  FreeAndNil(fGeometry);
  inherited Destroy;
end;


class function TNxMapRoadElementJunction.StrToJunctionType(aJunctionType: String): TNXMapRoadJunctionType;
var zs : string;
begin
  zs := UpperCase(StringReplace(aJunctionType, 'MSROPD_', '', []));
  result := TNXMapRoadJunctionType(GetEnumValue(System.TypeInfo(TNXMapRoadJunctionType), zs));
end;

procedure TNxMapRoadElementJunction.loadfromxml(aRoadElementJunctionNode : IXMLNode);
var aktNode,
   typeDataNode, reNode,
   geometryNode, cnode: IXMLNode;
   i, cid: integer;
begin  //  nicht getestet (keine Testdaten verfügbar)
  // typedata
  typeDataNode:= aRoadElementJunctionNode.childnodes.FindNode('typedata');
  aktNode:=  aRoadElementJunctionNode.childnodes.FindNode('JunctionType');
  if aktNode <> nil then fJunctionType:= StrToJunctionType(aktNode.NodeName);
  aktNode:=  aRoadElementJunctionNode.childnodes.FindNode('MiddlePointID');
  if aktNode <> nil then fMiddlePointID:= aktNode.NodeValue;
  aktNode:=  aRoadElementJunctionNode.childnodes.FindNode('RoadElementCount');
  if aktNode <> nil then fRoadElementCount:= aktNode.NodeValue;
  reNode:=  aRoadElementJunctionNode.childnodes.FindNode('RoadElementIDs');
  for i := 0 to reNode.childnodes.Count - 1 do
  begin
    aktNode:= reNode.childnodes.get(i);
    cid:= aktNode.NodeValue;
    fRoadElementIDs.Add(Pointer(cid));
  end;
  geometryNode:=  aRoadElementJunctionNode.childnodes.FindNode('geometry');
  // Inhalt? = <geometry primitive="point"><position lon="11.57079983" lat="50.91957474"/>
  if geometryNode <> nil
  then begin
    if geometryNode.HasAttribute('primitive')
    then begin
      if geometryNode.Attributes['primitive'] = 'point'
      then begin
        fMiddlePoint:= TGeoCoderPosition.Create;
        cnode:= geometryNode.ChildNodes.FindNode('position');
        fMiddlePoint.parseXMLPosition(cnode);
      end;
    end;
    // Weiter: parse attributes?
  end;
end;

{ **************************************************************************** }
{ ***** TNxMapIntersection *************************************************** }
{ **************************************************************************** }
constructor TNxMapIntersection.ceate;
begin
  inherited Create;
  fIntersectionType := TNXMap_RIT_None;
  fMiddlePointID    := 0;
  fOfficialNameID   := 0;
  fOfficialName     := '';
  fElementIDCount   := 0;
  fRoadElements     := THTTPMDSList.Create;
  fAttributes       := THTTPMDSList.Create;
end;

destructor TNxMapIntersection.destroy;
begin
  FreeAndNil(fRoadElements);
  FreeAndNil(fAttributes);
  inherited Destroy;
end;

{ **************************************************************************** }
{ ***** TNnxMapStreet ******************************************************** }
{ **************************************************************************** }

constructor TNnxMapStreet.Create;
begin
  inherited Create;
end;

destructor TNnxMapStreet.destroy;
begin
  inherited Destroy;
end;

{ **************************************************************************** }
{ ***** TNnxMapStreetCollection ********************************************** }
{ **************************************************************************** }
constructor TNnxMapStreetCollection.Create;
begin
  inherited Create;
end;

destructor TNnxMapStreetCollection.destroy;
begin
  inherited Destroy;
end;

{ **************************************************************************** }
{ ***** TNnxMapArea ********************************************************** }
{ **************************************************************************** }
constructor TNnxMapArea.Create;
begin
  inherited Create;
end;

destructor TNnxMapArea.Destroy;
begin
  inherited Destroy;
end;

{ **************************************************************************** }
{ ***** THTTPMDSMapElementAccess ********************************************* }
{ **************************************************************************** }

{ THTTPMDSMapElementAccess }
constructor THTTPMDSMapElementAccess.Create(AOwner: TComponent);
begin
  inherited create(AOwner);
  fHTTP := nil;
end;

destructor THTTPMDSMapElementAccess.Destroy;
begin
  fHTTP := nil;
  inherited;
end;

//  MapElement wird identifiziert durch mapcontextID, ro, rot, rost
function THTTPMDSMapElementAccess.getmapelement(amapcontextID: Integer; arot, aro, arost: Cardinal): TNnxMapElement;
var params : THTTPConnectorParams;
    ms : TMemoryStream;
begin
  result:= nil;
  if fHTTP = nil then
  begin
    raise EHTTPError.Create('can not perform action if http connector ist not assigned!');
  end;
  params := fHTTP.createParams;
  params.addInteger('mapcid', amapcontextID);
  params.addInteger('rost', arost);
  params.addInteger('ro',aro);
  params.addInteger('rot', arot);
  ms:= TMemoryStream.Create;
  try
    fHTTP.get(WMCMD_GETMAPELEMENT, params, ms);
    try
      ms.Position := 0;
      result  := TNnxMapElement.createFromStream(ms);
    except
      on e : exception do
      begin
        FreeAndNil(result);
        raise;
      end;
    end;
  finally
    if result.CopyStream then
    begin
      FreeAndNil(ms);
    end;
  end;
end;

function THTTPMDSMapElementAccess.findNearestMapElements(arot, arost: Cardinal; aLong, aLat: double; aRadius: double): TNnxMapElementList;
var params : THTTPConnectorParams;
    ms : TStream;
    meType: TMapElementType;
begin
  result:= nil;
  if fHTTP = nil then
  begin
    raise EHTTPError.Create('can not perform action if http connector ist not assigned!');
  end;
  params := fHTTP.createParams;
  params.addInteger('rot',arot);
  params.addInteger('rost',arost);
  params.addFloat('longitude', aLong);
  params.addFloat('latitude',aLat);
  params.addFloat('radius', aRadius);
  params.addString('outfmt', 'xml');
  ms:= TMemoryStream.Create;
  try
    ms.Position := 0;
    try
       fHTTP.get(WMCMD_FINDNEARESTMAPELEMENTS, params, ms); // schreibt das Ergebnis in den Strean ms
      // Test- URL: http://maps.navimatix.net:8086/findnearestmapelements?rot=20&rost=1&longitude=11.60000000&latitude=50.93000000&radius=0.00300000&outfmt=xml
      result:= TNnxMapElementList.createFromStream(ms); // im Stream sind mehrere MapElements enthalten
    except

    end;
  finally
    if result.CopyStream then
      begin
        FreeAndNil(ms);
      end;
   end;
 end;

function THTTPMDSMapElementAccess.rangequerymapelements(amapcid: integer; arot, arost: Cardinal; ageoleft, ageotop, ageoright, ageobottom: double): TNnxMapElementList;
// Ergebnis: Liste von MapElements
var
  params : THTTPConnectorParams;
  ms : TStream;
  meType: TMapElementType;
begin
  result:= nil;
  if fHTTP = nil then
  begin
    raise EHTTPError.Create('can not perform action if http connector ist not assigned!');
  end;
  params := fHTTP.createParams;
//Test: rot=20&rost=1&geoleft=11.07&geotop=50.700001&georight=11.070001&geobottom=50.7&mapcid=0}
  params.addInteger('rot',arot);
  params.addInteger('rost',arost);
  params.addFloat('geoleft'  , ageoleft);
  params.addFloat('geotop'   , ageotop);
  params.addFloat('georight' , ageoright);
  params.addFloat('geobottom', ageobottom);
  params.addInteger('mapcid' , amapcid);
  params.addString('outfmt', 'xml');
  ms:= TMemoryStream.Create;
  try
    ms.Position := 0;
    try
      fHTTP.get(WMCMD_RANGEQUERYMAPELEMENTS, params, ms); // schreibt das Ergebnis in den Strean ms
     // Test- URL: http://npc049:8086/rangequerymapelements?rot=20&rost=1&geoleft=11.07&geotop=50.700001&georight=11.070001&geobottom=50.7&mapcid=0
     // Stream auswerten
      result:= TNnxMapElementList.createFromStream(ms); // im Stream sind mehrere MapElements enthalten
    except

    end;
  finally
    if result.CopyStream then
      begin
        FreeAndNil(ms);
      end;
   end;
 end;

{ **************************************************************************** }
{ ***** TNnxMapElement ******************************************************* }
{ **************************************************************************** }
constructor TNnxMapElement.Create(CopyStreamOnLoad : Boolean = false);
begin
  inherited Create(CopyStreamOnLoad);
  fElementType  := T_UNDEFINED;
  fMapCID := 0;
  fMapID  := '';
  fRO     := 0;
  fROT    := 0;
  fROST   := 0;
end;

destructor TNnxMapElement.destroy;
begin
  inherited Destroy;
end;

procedure TNnxMapElement.internalLoadFromStream;
var
  cXMLdoc  :  IXMLDocument;
  aktNode,
  cRootNode,
  mapelementNode : IXMLNode;
  errStr   : String;
begin
   cXMLDoc := NewXMLDocument('1.0');
   cXMLdoc.LoadFromStream(fFromStream);
   cRootNode := cXMLDoc.ChildNodes.FindNode('namhttpservice');
   if cRootNode = nil then
   begin
     errStr:= 'node "namhttpservice" (root) not found';
     raise EParseError.Create(errStr, fFromStream);
     exit;
   end;

   if cRootNode.HasAttribute('mapcid') then
   begin
     fMapCID := cRootNode.Attributes['mapcid'];
   end else
   begin
     fMapCID := -1;
   end;
   createFromXML(mapelementNode);
end;

class function TNnxMapElement.createFromXML(aMapElementNode: IXmlNode): TNnxMapElement;
var
  ctype : String;
begin
  if aMapElementNode.HasAttribute('type') then ctype := aMapElementNode.Attributes['type'] else ctype := '';
  // Attributes['type'] definiert, welchen Typ das erzeugte Mapelement hat.
  result := createInstanceFromType(ctype);
  if aMapElementNode.HasAttribute('ro')   then result.fro    := aMapElementNode.Attributes['ro'];
  if aMapElementNode.HasAttribute('rot')  then result.frot   := aMapElementNode.Attributes['rot'];
  if aMapElementNode.HasAttribute('rost') then result.frost  := aMapElementNode.Attributes['rost'];
  try
    result.loadFromXML(aMapElementNode); // entsprechend Typ des erzeugten Mapelements wird die zutreffende loadFromXML aufgerufen
  except
    on e : exception do
    begin
      FreeAndNil(result);
      raise;
    end;
  end;
end;

class function TNnxMapElement.createFromStream(aFromStream : TStream): TNnxMapElement;
var cXMLdoc  :IXMLDocument;
  cRootNode,
  cElemNode  :IXMLNode;
  errStr     : String;
begin
  cXMLDoc := NewXMLDocument('1.0');
  cXMLdoc.LoadFromStream(aFromStream);
  cXMLdoc.SaveToFile('D:\temp\mapelement.xml');   // Nur für debug

  cRootNode := cXMLDoc.ChildNodes.FindNode('namhttpservice');
  if cRootNode = nil then
  begin
    errStr:= 'node "namhttpservice" (root) not found';
    raise EParseError.Create(errStr, aFromStream);
  end;
  cElemNode := cRootNode.ChildNodes.FindNode('mapelement');
  if cElemNode = nil then
  begin
    errStr:= 'node "mapelement" not found';
    raise EParseError.Create(errStr, aFromStream);
  end;
  result := createFromXML(cElemNode);
end;

// aTypeIdent definiert, welchen Typ das erzeugte Mapelement hat.
class function TNnxMapElement.createInstanceFromType(aTypeIdent : String): TNnxMapElement;
begin
  result  := nil;
  if aTypeIdent = 'TNaMRORoadElement' then
  begin
    result:= TNxMapRoadElement.create;
    result.fElementType:= TMapElementType.T_ROADELEMENT;
  end;
  if aTypeIdent = 'TNaMRORoadElementJunction' then
  begin
    result:= TNxMapRoadElementJunction.create;
    result.fElementType:= TMapElementType.T_ROADELEMENTJUNCTION;
  end;
  if aTypeIdent = 'TNaMROIntersection' then
  begin
    result:= TNxMapIntersection.create;
    result.fElementType:= TMapElementType.T_INTERSECTION;
  end;
  if aTypeIdent = 'TNaMROStreet' then
  begin
    result:= TNnxMapStreet.create;
    result.fElementType:= TMapElementType.T_STREET;
  end;
  if aTypeIdent = 'TNaMROStreetCollection' then
  begin
    result:= TNnxMapStreetCollection.create;
    result.fElementType:= TMapElementType.T_STREETCOLLECTION;
  end;
  if aTypeIdent = 'TNaMROArea' then
  begin
    result:= TNnxMapArea.create;
    result.fElementType:= TMapElementType.T_AREA;
  end;
  if aTypeIdent = 'TNaMROServicePoint' then
  begin
    result:= TNnxMapServicePoint.create;
    result.fElementType:= TMapElementType.T_SERVICEPOINT;
  end;
end;

class function TNnxMapElement.StrToRoadElementType(aRoadElemType: String):TRoadType;
var zs : string;
begin
  zs := StringReplace(aRoadElemType, 'MSROPD_', '', []);
  result := TRoadType(GetEnumValue(System.TypeInfo(TRoadType), zs));
end;

class function TNnxMapElement.StrToFunctionalRoadClass(aRoadClass: String): TFunctionalRoadClass;
var zs : string;
begin
  zs := StringReplace(aRoadClass, 'MSROPD_', '', []);
  result := TFunctionalRoadClass(GetEnumValue(System.TypeInfo(TFunctionalRoadClass), zs));
end;

class function TNnxMapElement.StrToFormOfWay(aFormOfWay: String): TFormOfWay;
var zs : string;
begin
  zs := StringReplace(aFormOfWay, 'MSROPD_', '', []);
  result := TFormOfWay(GetEnumValue(System.TypeInfo(TFormOfWay), zs));
end;

class function TNnxMapElement.StrToBlockedPassage(aBlockedPassage: String):TBlockedPassage;
var zs : string;
begin
  zs := StringReplace(aBlockedPassage, 'MSROPD_', '', []);
  result := TBlockedPassage(GetEnumValue(System.TypeInfo(TBlockedPassage), zs));
end;

class function TNnxMapElement.StrTotMainDirectionFlow(aMainDirectionFlow: String):TMainDirectionFlow;
var zs : string;
begin
  zs := StringReplace(aMainDirectionFlow, 'MSROPD_', '', []);
  result := TMainDirectionFlow(GetEnumValue(System.TypeInfo(TMainDirectionFlow), zs));
end;

class function TNnxMapElement.StrToConstructionState(aConstructionState: String): TConstructionState;
var zs : string;
begin
  zs := StringReplace(aConstructionState, 'MSROPD_', '', []);
  result := TConstructionState(GetEnumValue(System.TypeInfo(TConstructionState), zs));
end;

procedure TNnxMapElement.loadFromXML(aMapElementNode: IXmlNode);
begin
  // allgemeines Laden ro, rot, rost.....
  fRO  := aMapElementNode.Attributes['ro'];
  fROT := aMapElementNode.Attributes['rot'];
  fROST:= aMapElementNode.Attributes['rost'];
end;

{ **************************************************************************** }
{ ***** TNnxMapElementList *************************************************** }
{ **************************************************************************** }
constructor TNnxMapElementList.Create(CopyStreamOnLoad : Boolean = false);
begin
  inherited Create(CopyStreamOnLoad);
  fMapElements:= TList.Create;
end;

destructor TNnxMapElementList.Destroy;
begin
  FreeAndNil(fMapElements);
  inherited Destroy;
end;


class function TNnxMapElementList.createFromStream(aFromStream : TStream): TNnxMapElementList;
var cXMLdoc  :IXMLDocument;
  cRootNode,
  cMapObjectsNode,
  aktNode    : IXMLNode;
  errStr     : String;
  cme        : TNnxMapElement;
  i          : Integer;
begin
  cXMLDoc := NewXMLDocument('1.0');
  cXMLdoc.LoadFromStream(aFromStream);
  cXMLdoc.SaveToFile('D:\temp\mapelements.xml');
  cRootNode := cXMLDoc.ChildNodes.FindNode('namhttpservice');

  if cRootNode = nil then
  begin
    errStr:= 'node "namhttpservice" (root) not found';
    raise EParseError.Create(errStr, aFromStream);
  end;
  result := TNnxMapElementList.Create;
  cMapObjectsNode := cRootNode.ChildNodes.FindNode('mapobjects');
  if cMapObjectsNode <> nil
  then begin // Stream enthält MapObjects
    if cMapObjectsNode.HasAttribute('mapcid') then result.fmapcid:= cMapObjectsNode.Attributes['mapcid'];
    if cMapObjectsNode.HasAttribute('mapid')  then result.fmapid := cMapObjectsNode.Attributes['mapid'];
    for i:= 0 to cMapObjectsNode.ChildNodes.Count - 1 do
    begin
      aktNode:= cMapObjectsNode.ChildNodes.get(i);
      cme    := TNnxMapElement.createFromXML(aktNode);
      cme.fMapID := result.fmapid;
      cme.fMapCID:= result.fmapcid;
      result.MapElements.Add(Pointer(TNnxMapElement(cme)));
    end;
  end;
end;

initialization
  initXMLSchemaDataTypesV2FormatSettings(MapServerFS);

end.
