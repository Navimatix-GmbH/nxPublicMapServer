unit uhttpmdsroutecalculation;

interface

uses types, classes, SysUtils,
     XMLIntf, XMLDoc, TypInfo,
     uhttpmdsbase, uhttpmdsgeocoding, uhttpmdsmapelementbase;


type
  // Data Structures
  TRouteCalculatorAddress = class
  private
    fCountry          : String;
    fCountryCode      : String;
    fCountryPart      : String;
    fCountryDistrict  : String;
    fCity             : String;
    fCityPart         : String;
    fStreet           : String;
    fHouse            : String;
    fZipCode          : String;
    fBuilding         : String;
    fMapCID           : Integer;

  public
    constructor Create; overload;
    constructor Create (aCountry, aCountryPart, aCountryDistrict, aCountryCode, aCity, aCityPart,
                        aStreet, aHouse, aZipCode, aBuilding : String; aMapCID : Integer); overload;
    destructor  Destroy; override;

    property Country          : String read fCountry write fCountry;
    property CountryPart      : String read fCountryPart write fCountryPart;
    property CountryDistrict  : String read fCountryDistrict write fCountryDistrict;
    property CountryCode      : String read fCountryCode write fCountryCode;
    property City             : String read fCity write fCity;
    property CityPart         : String read fCityPart write fCityPart;
    property Street           : String read fStreet write fStreet;
    property House            : String read fHouse write fHouse;
    property ZipCode          : String read fZipCode write fZipCode;
    property Building         : String read fBuilding write fBuilding;
    property MapCid           : Integer read fMapCID write fMapCID;
  end;

  TRouteCalculatorAddressEx = class (TRouteCalculatorAddress)
  private
    fAdminId         : Cardinal;
    fStreetId        : Cardinal;
    fRoadElementId   : Cardinal;

  public
    constructor Create;
    destructor  Destroy; override;

    property AdminId       : Cardinal read fAdminId write fAdminId;
    property StreetId      : Cardinal read fStreetId write fStreetId;
    property RoadElementId : Cardinal read fRoadElementId write fRoadElementId;
  end;

  TRouteCalculatorAttribute = class  // Description of a single attribute
  protected
    fId           : Cardinal;
    fType         : Cardinal;
    fTypeString   : String;
    fValue        : Cardinal;
    fValueString  : String;
  public
    constructor Create; reintroduce; virtual;
    destructor Destroy; override;

    property Id              : Cardinal read fId;
    property AttType         : Cardinal read fType;
    property AttTypeString   : String read fTypeString;
    property AttValue        : Cardinal read fValue;
    property AttValueString  : String read fValueString;
  end;

  TTurnType = (
    T_STRAIGHTFORWARD,
    T_EASILYLEFT,
    T_EASILYRIGHT,
    T_LEFT,
    T_RIGHT,
    T_STRONGLYLEFT,
    T_STRONGLYRIGHT,
    T_EXTREMELYSTRONGLYLEFT,
    T_EXTREMELYSTRONGLYRIGHT,
    T_UTURN,
    T_DESTINATIONREACHED,

    T_ENTERROUNDABOUT,    // in Kreisverkehr einfahrren
    T_LEAVEROUNDABOUT,    // aus Kreisverkehr abfahren

    T_ENTERMOTORWAY,      // auf Autobahn auffahren
    T_LEAVEMOTORWAY,      // von Autobahn abfahren
    T_CHANGEMOTORWAY,     // von Autobahn auf andere Autobahn fahren

    T_GoBackToRoute
  );

  TRouteType = (RT_SHORTEST, RT_FASTEST);

  TRoadElement = class
  private
    frot, frost, fro: Integer;
    fElementType: TRoadType;
    fFunctionalRoadClass: TFunctionalRoadClass;
    fThroughTraffic: Boolean;
    fFormOfWay: TFormOfWay;
    fBlockedPassage: TBlockedPassage;
    fMainDirectionFlow: TMainDirectionFlow;
    fLength: Cardinal;
    fConstructionState: TConstructionState;
    fMaxSpeed: Byte;
    fAverageSpeed: Byte;
    fStartJunctionID: Cardinal;
    fEndJunctionID: Cardinal;
    fOfficialNameID: Cardinal;
    fOfficialName: string;
    fRouteNumberID: Cardinal;
    fRouteNumber: string;
    fGeometry: THTTPMDSList;
    fAttributes: THTTPMDSList;
  protected
    function GetToString: String;

    function getPositionCount : Integer;
    function getPosition(index : Integer) : TGeoCoderPosition;
    function getAttributeCount : Integer;
    function getAttribute(index : Integer) : TRouteCalculatorAttribute;
  public
    constructor Create; reintroduce; virtual;
    destructor Destroy; override;

    property ElementType: TRoadType read fElementType write fElementType;
    property FunctionalRoadClass: TFunctionalRoadClass read fFunctionalRoadClass write fFunctionalRoadClass;
    property ThroughTraffic: Boolean read fThroughTraffic write fThroughTraffic;
    property FormOfWay: TFormOfWay read fFormOfWay write fFormOfWay;
    property BlockedPassage: TBlockedPassage read fBlockedPassage write fBlockedPassage;
    property MainDirectionFlow: TMainDirectionFlow read fMainDirectionFlow write fMainDirectionFlow;
    property Length: Cardinal read fLength write fLength;
    property ConstructionState: TConstructionState read fConstructionState write fConstructionState;
    property MaxSpeed: Byte read fMaxSpeed write fMaxSpeed;
    property AverageSpeed: Byte read fAverageSpeed write fAverageSpeed;
    property StartJunctionID: Cardinal read fStartJunctionID write fStartJunctionID;
    property EndJunctionID: Cardinal read fEndJunctionID write fEndJunctionID;
    property OfficialNameID: Cardinal read fOfficialNameID write fOfficialNameID;
    property OfficialName: string read fOfficialName write fOfficialName;
    property RouteNumberID: Cardinal read fRouteNumberID write fRouteNumberID;
    property RouteNumber: string read fRouteNumber write fRouteNumber;
    property AsString: string read GetToString;

    property PositionCount : Integer read getPositionCount;
    property Positions[index : Integer] : TGeoCoderPosition read getPosition;

    property AttributeCount : Integer read getAttributeCount;
    property Attributes[index : Integer] : TRouteCalculatorAttribute read getAttribute;
  end;

  TRouteItem = class
  private
    fElementId: Cardinal;
    fElementDirection: Boolean;
    fElement: TRoadElement;
  protected
    function GetToString: String;
  public
    constructor Create; reintroduce; virtual;
    destructor Destroy; override;

    property Id: Cardinal read fElementId write fElementId;
    property Direction: Boolean read fElementDirection write fElementDirection;
    property Element: TRoadElement read fElement write fElement;
    property AsString: String read GetToString;
  end;

  TTurn= class
  protected
    function GetToString: String;
  private
    fduration: Single;
    fturntype: TTurnType;
    fangle: Single;
    ftoid: Cardinal;
    ffromid: Cardinal;
    fpos: TGeoCoderPosition;
    fcommand: String;
    fdescription: string;
  public
    constructor Create; reintroduce; virtual;
    destructor Destroy; override;

    property Duration: Single read fduration;
    property TurnType: TTurnType read fturntype;
    property Angle: Single read fangle;
    property Toid: Cardinal read ftoid;
    property Fromid: Cardinal read ffromid;
    property Pos: TGeoCoderPosition read fpos;
    property Command: String read fcommand;
    property Description: string read fdescription;
    property ToString: String read GetToString;
  end;

  TRouteGuidance= class
  public
    duration: Extended;
    length: Extended;
    name: string;
  end;

  TRouteCalculatorRoute = class(THTTPConnectorResult)
  protected
    fMapCID: Integer;
    fMapID: String;
    fDuration: Double;
    fLength: Double;

    fRequestedStartPosition : TGeoCoderPosition;
    fRequestedDestinationPosition : TGeoCoderPosition;

    fMatchedStartPosition : TGeoCoderPosition;
    fMatchedDestinationPosition : TGeoCoderPosition;

    //fRouteStartAddress: TRouteCalculatorAddress;
    fRouteStartAddressEx: TRouteCalculatorAddressEx;
    //fRouteDestinationAddress: TRouteCalculatorAddress;
    fRouteDestinationAddressEx: TRouteCalculatorAddressEx;

    fRouteItems: Array of TRouteItem; // contain ElementId, ElementDirection, RoadElement
    fGeometryPositions : Array of TGeoCoderPosition;
    fRoutePositions : Array of TGeoCoderPosition;
    fRouteTurns: Array of TTurn;

    function getRouteItem(index: Integer): TRouteItem;
    function getRouteItemsCount: Integer;
    function GetToString: String;
    function getPositionsCount: Integer;
    function GetPosition(index: Integer): TGeoCoderPosition;
    function getRouteTurnsCount: Integer;
    function GetTurn(index: Integer): TTurn;

    procedure internalLoadFromStream; override;
  public
    constructor Create(CopyStreamOnLoad : Boolean = false); override;
    destructor Destroy; override;

    property MapCID: Integer read fMapCID;
    property MapID: String read fMapID;
    property Duration: Double read fDuration;
    property RouteLength: Double read fLength;

    property RequestedStartPosition : TGeoCoderPosition read fRequestedStartPosition;
    property RequestedDestinationPosition : TGeoCoderPosition read fRequestedDestinationPosition;

    property MatchedStartPosition : TGeoCoderPosition read fMatchedStartPosition;
    property MatchedDestinationPosition : TGeoCoderPosition read fMatchedDestinationPosition;

    //property RouteStartAddress: TRouteCalculatorAddress read fRouteStartAddress;
    property RouteStartAddressEx: TRouteCalculatorAddressEx read fRouteStartAddressEx;
    //property RouteDestinationAddress: TRouteCalculatorAddress read fRouteDestinationAddress;
    property RouteDestinationAddressEx: TRouteCalculatorAddressEx read fRouteDestinationAddressEx;

    property RouteItem[Index:Integer]: TRouteItem read getRouteItem;
    property RouteItemCount: Integer read getRouteItemsCount;
    property AsString: String read GetToString;

    property PositionCount: Integer read getPositionsCount;
    property Positions[Index:Integer]: TGeoCoderPosition read GetPosition;

    property Turns[Index:Integer]: TTurn read GetTurn;
    property TurnCount: Integer read getRouteTurnsCount;
  end;

  // TRoute Calculator Component class - abstract base component class for use with any protocol
  TRouteCalculator = class(TComponent)
  public
    function calculateRouteByGeoPositions(const aMapId : Integer; const aStartLon, aStartLat, aDestinationLon, aDestinationLat : Double;
      const aRouteType : TRouteType; const aRoutePrecision : Double = 1.6;
      aDetailPositions : Boolean = true; aDetailItems : Boolean = true; aDetailTurns : Boolean = true
      ): TRouteCalculatorRoute; overload; virtual; abstract;

    function findRouteByGeoPositions(const aMapId : Integer; const asourcestream : TStream;
      alookahead : Integer = 2; awayforms : String = ''; aDetailPositions : Boolean = true; aDetailItems : Boolean = true; aDetailTurns : Boolean = true
      ) : TRouteCalculatorRoute; overload; virtual; abstract;

    function calculateRouteByGeoPositions(aResultToStream : TStream; const aMapId : Integer; const aStartLon, aStartLat, aDestinationLon, aDestinationLat : Double;
      const aRouteType : TRouteType; const aRoutePrecision : Double = 1.6;
      aDetailPositions : Boolean = true; aDetailItems : Boolean = true; aDetailTurns : Boolean = true
      ): TRouteCalculatorRoute; overload; virtual; abstract;

    function findRouteByGeoPositions(aResultToStream : TStream; const aMapId : Integer; const asourcestream : TStream;
      alookahead : Integer = 2; awayforms : String = ''; aDetailPositions : Boolean = true; aDetailItems : Boolean = true; aDetailTurns : Boolean = true
      ) : TRouteCalculatorRoute; overload; virtual; abstract;

    constructor Create(AOwner : TComponent); override;
    destructor  Destroy; override;
  end;

  // Route CalculatorHTTP = Route Calculator class for HTTP protocol
  TRouteCalculatorHTTP = class(TRouteCalculator)
  private
    fHTTP : THTTPConnector;
  public
    function calculateRouteByGeoPositions(const aMapId : Integer; const aStartLon, aStartLat, aDestinationLon, aDestinationLat : Double;
      const aRouteType : TRouteType; const aRoutePrecision : Double = 1.6;
      aDetailPositions : Boolean = true; aDetailItems : Boolean = true; aDetailTurns : Boolean = true
      ): TRouteCalculatorRoute; override;

    function findRouteByGeoPositions(const aMapId : Integer; const asourcestream : TStream;
      alookahead : Integer = 2; awayforms : String = ''; aDetailPositions : Boolean = true; aDetailItems : Boolean = true; aDetailTurns : Boolean = true
      ) : TRouteCalculatorRoute; override;

    function calculateRouteByGeoPositions(aResultToStream : TStream; const aMapId : Integer; const aStartLon, aStartLat, aDestinationLon, aDestinationLat : Double;
      const aRouteType : TRouteType; const aRoutePrecision : Double = 1.6;
      aDetailPositions : Boolean = true; aDetailItems : Boolean = true; aDetailTurns : Boolean = true
      ): TRouteCalculatorRoute; override;

    function findRouteByGeoPositions(aResultToStream : TStream; const aMapId : Integer; const asourcestream : TStream;
      alookahead : Integer = 2; awayforms : String = ''; aDetailPositions : Boolean = true; aDetailItems : Boolean = true; aDetailTurns : Boolean = true
      ) : TRouteCalculatorRoute; override;

    constructor Create(AOwner : TComponent); override;
    destructor  Destroy; override;

  published
    property HTTP : THTTPConnector read fHTTP write fHTTP;
  end;

function parseXMLPosition(aBaseNode : IXMLNode; aPosition : TGeoCoderPosition) : Boolean;
function parseXMLAttribute(aBaseNode : IXMLNode; aAttribute: TRouteCalculatorAttribute): Boolean;
function parseXMLAddressEx(aBaseNode : IXMLNode; aAddress : TRouteCalculatorAddressEx) : Boolean;
function parseXMLRouteItem(aBaseNode : IXMLNode; aRouteItem : TRouteItem) : Boolean;
function parseXMLTurn(aBaseNode : IXMLNode; aTurn : TTurn) : Boolean;
function parseXMLRoadElement(aBaseNode : IXMLNode; aRoadElement : TRoadElement) : Boolean;


implementation

uses Math;

// ****************************************************************************
// ***** TRouteCalculatorPosition *********************************************
// ****************************************************************************
{
constructor TRouteCalculatorPosition.Create;
begin
  inherited Create;
  fLongitude := nan;
  fLatitude := nan;
end;

constructor TRouteCalculatorPosition.Create(aLongitude, aLatitude : Double);
begin
  inherited Create;
  fLongitude  := aLongitude;
  fLatitude   := aLatitude;
end;

destructor TRouteCalculatorPosition.Destroy;
begin
  inherited Destroy;
end;

function TRouteCalculatorPosition.getToString;
var sl : TStringList;
begin
  sl  := TStringList.Create;
  try
    sl.Add('RouteCalculatorPosition:');
    sl.Add('Longitude= '+ FloatToStrF(fLongitude,ffFixed,10,6));
    sl.Add('Latitude= ' + FloatToStrF(fLatitude,ffFixed,10,6));
    result  := sl.Text;
  finally
    FreeAndNil(sl);
  end;
  {
  result:= 'RouteCalculatorPosition:' + #13 +
           'Longitude= '+ FloatToStrF(fLongitude,ffFixed,10,6) + #13 +
           'Latitude= ' + FloatToStrF(fLatitude,ffFixed,10,6);

end; }

// ****************************************************************************
// ***** TRouteCalculatorAddress **********************************************
// ****************************************************************************
constructor TRouteCalculatorAddress.Create;
begin
  inherited Create;
  fCountry         := '';
  fCountryPart     := '';
  fCountryDistrict := '';
  fCountryCode     := '';
  fCity            := '';
  fCityPart        := '';
  fStreet          := '';
  fHouse           := '';
  fZipCode         := '';
  fBuilding        := '';
  fMapCID          := -1;
end;

constructor TRouteCalculatorAddress.Create(aCountry, aCountryPart, aCountryDistrict, aCountryCode, aCity,
                                     aCityPart, aStreet, aHouse, aZipCode, aBuilding: string; aMapCID : Integer);
begin
  inherited Create;
  fCountry         := aCountry;
  fCountryPart     := aCountryPart;
  fCountryDistrict := aCountryDistrict;
  fCountryCode     := aCountryCode;
  fCity            := aCity;
  fCityPart        := aCityPart;
  fStreet          := aStreet;
  fHouse           := aHouse;
  fZipCode         := aZipCode;
  fBuilding        := aBuilding;
  fMapCID          := aMapCID;
end;


destructor TRouteCalculatorAddress.Destroy;
begin
  inherited Destroy;
end;


// ****************************************************************************
// ***** TRouteCalculatorAddressEx ********************************************
// ****************************************************************************

constructor TRouteCalculatorAddressEx.Create;
begin
  inherited Create;
  fAdminId := 0;
  fStreetId := 0;
  fRoadElementId := 0;
end;

destructor TRouteCalculatorAddressEx.Destroy;
begin
  inherited Destroy;
end;

// ****************************************************************************

function parseXMLPosition(aBaseNode : IXMLNode; aPosition : TGeoCoderPosition) : Boolean;
begin
  if (aBaseNode <> nil) and
     (aPosition <> nil) and
     aBaseNode.HasAttribute('lon') and
     aBaseNode.HasAttribute('lat') then
  begin
    with aPosition do // aposition lat: double lon: double
    begin
      aPosition.Longitude:= StrToFloatDef(aBaseNode.Attributes['lon'], nan, HTTPMDSFormatSettings);
      aPosition.Latitude:= StrToFloatDef(aBaseNode.Attributes['lat'], nan, HTTPMDSFormatSettings);
    end;
    result:= True;
  end else
  begin
    result:= False;
  end;
end;

function parseXMLAttribute(aBaseNode : IXMLNode; aAttribute: TRouteCalculatorAttribute): Boolean;
var aktNode: IXMLNode;
begin
  result:= false;
  if (aBaseNode <> nil) and (aAttribute <> nil) then
  begin
    if aBaseNode.HasAttribute('id') then
    begin
      aAttribute.fId := StrToIntDef(aBaseNode.Attributes['id'], 0);
      aktNode := aBaseNode.ChildNodes.FindNode('type');
      if aktNode <> nil then
      begin
        aAttribute.fType  := StrToIntDef(aktNode.Attributes['value'], 0);
        aAttribute.fTypeString := aktNode.Text;
      end;
      aktNode := aBaseNode.ChildNodes.FindNode('value');
      if aktNode <> nil then
      begin
        aAttribute.fValue  := StrToIntDef(aktNode.Attributes['value'], 0);
        aAttribute.fValueString := aktNode.Text;
      end;
      result  := true;
    end;
  end;
end;

function parseXMLAddressEx(aBaseNode : IXMLNode; aAddress : TRouteCalculatorAddressEx) : Boolean;
begin
  if (aBaseNode <> nil) and (aAddress <> nil) then
  begin
    with aAddress do
    begin
      if aBaseNode.HasAttribute('country') then country:= aBaseNode.Attributes['country']; // "Deutschland"
      if aBaseNode.HasAttribute('countrycode') then countrycode:= aBaseNode.Attributes['countrycode']; // "DE"
      if aBaseNode.HasAttribute('countrypart') then countrypart:= aBaseNode.Attributes['countrypart']; // "Thüringen"
      if aBaseNode.HasAttribute('countrydistrict') then countrydistrict:= aBaseNode.Attributes['countrydistrict'];// "Jena"
      if aBaseNode.HasAttribute('city') then city:= aBaseNode.Attributes['city'];// "Jena"
      if aBaseNode.HasAttribute('citypart') then citypart:= aBaseNode.Attributes['citypart'];//""
      if aBaseNode.HasAttribute('street') then street:= aBaseNode.Attributes['street'];//"Lichtenhainer Straße"
      if aBaseNode.HasAttribute('house') then house:=aBaseNode.Attributes['house'];//"6"
      if aBaseNode.HasAttribute('zipcode') then zipcode:=aBaseNode.Attributes['zipcode'];//"07745"
      if aBaseNode.HasAttribute('building') then building:=aBaseNode.Attributes['building'];// ""
      if aBaseNode.HasAttribute('administrationid') then AdminId:= aBaseNode.Attributes['administrationid'];//"86497"
      if aBaseNode.HasAttribute('streetid') then StreetId:= aBaseNode.Attributes['streetid']; //"1613825"
      if aBaseNode.HasAttribute('streetname') then Street:= aBaseNode.Attributes['streetname']; //"Lichtenhainer Straße"
    end;
    result := true;
  end else
  begin
    result := false;
  end;
end;

function StrToRoadElementType(aRoadElemType: String):TRoadType;
var zs : string;
begin
  zs := StringReplace(aRoadElemType, 'MSROPD_', '', []);
  result := TRoadType(GetEnumValue(System.TypeInfo(TRoadType), zs));
end;

function StrToFunctionalRoadClass(aRoadClass: String): TFunctionalRoadClass;
var zs : string;
begin
  zs := StringReplace(aRoadClass, 'MSROPD_', '', []);
  result := TFunctionalRoadClass(GetEnumValue(System.TypeInfo(TFunctionalRoadClass), zs));
end;

function StrToFormOfWay(aFormOfWay: String): TFormOfWay;
var zs : string;
begin
  zs := StringReplace(aFormOfWay, 'MSROPD_', '', []);
  result := TFormOfWay(GetEnumValue(System.TypeInfo(TFormOfWay), zs));
end;

function StrToBlockedPassage(aBlockedPassage: String):TBlockedPassage;
var zs : string;
begin
  zs := StringReplace(aBlockedPassage, 'MSROPD_', '', []);
  result := TBlockedPassage(GetEnumValue(System.TypeInfo(TBlockedPassage), zs));
end;

function StrTotMainDirectionFlow(aMainDirectionFlow: String):TMainDirectionFlow;
var zs : string;
begin
  zs := StringReplace(aMainDirectionFlow, 'MSROPD_', '', []);
  result := TMainDirectionFlow(GetEnumValue(System.TypeInfo(TMainDirectionFlow), zs));
end;

function StrToConstructionState(aConstructionState: String): TConstructionState;
var zs : string;
begin
  zs := StringReplace(aConstructionState, 'MSROPD_', '', []);
  result := TConstructionState(GetEnumValue(System.TypeInfo(TConstructionState), zs));
end;

function StrToTurnType(aTurnType: String): TTurnType;
var zs : string;
begin
  zs := StringReplace(aTurnType, 'NaMTC', 'T', []);
  result := TTurnType(GetEnumValue(System.TypeInfo(TTurnType), zs));
end;

{function StrToAttType(aAttType: String): Integer;
//var zs : string;
begin
  {zs := StringReplace(aAttType, 'MSROPD_', '', []);
  result := TAttType(GetEnumValue(System.TypeInfo(TAttType), zs)
  Geht so nicht, weil   ATTTYPE_... Ganzzahl- Konstanten sind.;
  Kann man hier evtl. etwas wie TNaMROMapKnowledge.initAttributeTypeNames und
  anschließender Verwendung von IndexOf(aToStrings) machen?
  Das macht letztendlich aber auch nichts anderes als hier implementiert ist.}


  {result:= ATTTYPE_NONE;
  if (aAttType= 'ATTTYPE_HOUSENUMBERSTRUCTURE') then result:= ATTTYPE_HOUSENUMBERSTRUCTURE
    else
    if (aAttType= 'ATTTYPE_FIRSTHOUSENUMBERLEFT') then result:= ATTTYPE_FIRSTHOUSENUMBERLEFT
      else
      if (aAttType= 'ATTTYPE_FIRSTHOUSENUMBERRIGHT') then result:= ATTTYPE_FIRSTHOUSENUMBERRIGHT
        else
        if (aAttType= 'ATTTYPE_LASTHOUSENUMBERLEFT') then result:= ATTTYPE_LASTHOUSENUMBERLEFT
          else
          if (aAttType= 'ATTTYPE_LASTHOUSENUMBERRIGHT') then result:= ATTTYPE_LASTHOUSENUMBERRIGHT
            else
            if (aAttType= 'ATTTYPE_STREETIDENTIFIER') then result:= ATTTYPE_STREETIDENTIFIER
              else
              if (aAttType= 'ATTTYPE_STREETNAME') then result:= ATTTYPE_STREETNAME
                else
                 if (aAttType= 'ATTTYPE_NAMSTREETID') then result:= ATTTYPE_NAMSTREETID
                  else
                  if (aAttType= 'ATTTYPE_PARTOFINTERSECTION') then result:= ATTTYPE_PARTOFINTERSECTION
                    else
                    if (aAttType= 'ATTTYPE_ROUTENUMBER_NATIONAL') then result:= ATTTYPE_ROUTENUMBER_NATIONAL
                      else
                      if (aAttType= 'ATTTYPE_ROUTENUMBER_INTERNATIONAL') then result:= ATTTYPE_ROUTENUMBER_INTERNATIONAL
                        else
                        if (aAttType= 'ATTTYPE_ZIPCODEBELONGSTO') then result:= ATTTYPE_ZIPCODEBELONGSTO
                          else
                          if (aAttType= 'ATTTYPE_BELONGSTOTEXT') then result:= ATTTYPE_BELONGSTOTEXT
                            else
                            if (aAttType= 'ATTTYPE_BELONGSTOZIPCODETEXT') then result:= ATTTYPE_BELONGSTOZIPCODETEXT
                              else
                              if (aAttType= 'ATTTYPE_BELONGSTOSTREETTEXT') then result:= ATTTYPE_BELONGSTOSTREETTEXT
                                else
                                if (aAttType= 'ATTTYPE_BELONGSTOHOUSENUMBERTEXT') then result:= ATTTYPE_BELONGSTOHOUSENUMBERTEXT
                                  else
                                  if (aAttType= 'ATTTYPE_BELONGSTOCOUNTRYTEXT') then result:= ATTTYPE_BELONGSTOCOUNTRYTEXT
                                    else
                                    if (aAttType= 'ATTTYPE_BELONGSTOCITYTEXT') then result:= ATTTYPE_BELONGSTOCITYTEXT
                                      else
                                      if (aAttType= 'ATTTYPE_BELONGSTOADMINTEXTLEVEL') then result:= ATTTYPE_BELONGSTOADMINTEXTLEVEL
                                        else
                                        if (aAttType= 'ATTTYPE_PROHIBITEDVIAROADELEMENT_POS_ID') then result:= ATTTYPE_PROHIBITEDVIAROADELEMENT_POS_ID
                                          else
                                          if (aAttType= 'ATTTYPE_PROHIBITEDTOROADELEMENT_POS_ID') then result:= ATTTYPE_PROHIBITEDTOROADELEMENT_POS_ID
                                            else
                                            if (aAttType= 'ATTTYPE_PROHIBITEDVIAROADELEMENT_NEG_ID') then result:= ATTTYPE_PROHIBITEDVIAROADELEMENT_NEG_ID
                                              else
                                              if (aAttType= 'ATTTYPE_PROHIBITEDTOROADELEMENT_NEG_ID') then result:= ATTTYPE_PROHIBITEDTOROADELEMENT_NEG_ID
                                                else
                                                if (aAttType= 'ATTTYPE_RESTRICTEDVIAROADELEMENT_POS_ID') then result:= ATTTYPE_RESTRICTEDVIAROADELEMENT_POS_ID
                                                  else
                                                  if (aAttType= 'ATTTYPE_RESTRICTEDTOROADELEMENT_POS_ID') then result:= ATTTYPE_RESTRICTEDTOROADELEMENT_POS_ID
                                                    else
                                                    if (aAttType= 'ATTTYPE_RESTRICTEDVIAROADELEMENT_NEG_ID') then result:= ATTTYPE_RESTRICTEDVIAROADELEMENT_NEG_ID
                                                      else
                                                      if (aAttType= 'ATTTYPE_RESTRICTEDTOROADELEMENT_NEG_ID') then result:= ATTTYPE_RESTRICTEDTOROADELEMENT_NEG_ID
                                                        else
                                                        if (aAttType= 'atttype_priorityviaroadelement_pos_id') then result:= atttype_priorityviaroadelement_pos_id
                                                          else
                                                          if (aAttType= 'atttype_prioritytoroadelement_pos_id') then result:= atttype_prioritytoroadelement_pos_id
                                                            else
                                                            if (aAttType= 'atttype_priorityviaroadelement_neg_id') then result:= atttype_priorityviaroadelement_neg_id
                                                              else
                                                              if (aAttType= 'atttype_prioritytoroadelement_neg_id') then result:= atttype_prioritytoroadelement_neg_id
                                                                else
                                                                if (aAttType= 'atttype_addressformat_left') then result:= atttype_addressformat_left
                                                                  else
                                                                  if (aAttType= 'atttype_addressformat_right') then result:= atttype_addressformat_right
                                                                    else
                                                                    if (aAttType= 'atttype_addresssceme_left') then result:= atttype_addresssceme_left
                                                                      else
                                                                      if (aAttType= 'atttype_addresssceme_right') then result:= atttype_addresssceme_right
                                                                        else
                                                                        if (aAttType= 'atttype_addresstype') then result:= atttype_addresstype
                                                                          else
                                                                          if (aAttType= 'atttype_speedcategory') then result:= atttype_speedcategory
                                                                            else
                                                                            if (aAttType= 'atttype_throughtraffic') then result:= atttype_throughtraffic
                                                                              else
                                                                              if (aAttType= 'atttype_urbanlink') then result:= atttype_urbanlink
                                                                                else
                                                                                if (aAttType= 'atttype_istollroad') then result:= atttype_istollroad
                                                                                  else
                                                                                  if (aAttType= 'atttype_administrativelevel') then result:= atttype_administrativelevel;
end;   }


function parseXMLRouteItem(aBaseNode : IXMLNode; aRouteItem : TRouteItem) : Boolean;
var elemNode : IXMLNode;
    ctype : String;
    cre : TRoadElement;
begin
  if (aBaseNode <> nil) and (aRouteItem <> nil) then
  begin
    //with aRouteItem do
    begin
      // parse routeitem element
      // Es wird unterstellt, dass für jedes RouteItem genau ein Element definiert ist.
      // Andernfalls muss hierfür ein RouteElement- Array verwendet werden.
      elemNode:= aBaseNode.ChildNodes.FindNode('element');
      if (elemNode <> nil) then
      begin
        if elemNode.HasAttribute('type') then ctype:= elemNode.Attributes['type'];
        if lowercase(ctype) = lowercase('TNaMRORoadElement') then
        begin
          cre := TRoadElement.Create;
          try
            if elemNode.HasAttribute('ro') then cre.fro:= StrToIntDef(elemNode.Attributes['ro'], 0);
            if elemNode.HasAttribute('rost') then cre.frost:= StrToIntDef(elemNode.Attributes['rost'], 0);
            if elemNode.HasAttribute('rot') then cre.frot:= StrToIntDef(elemNode.Attributes['rot'], 0);
            if parseXMLRoadElement(elemNode, cre) then
            begin
              aRouteItem.Element  := cre;
            end else
            begin
              FreeAndNil(cre);
            end;
          except
            on e : exception do
            begin
              FreeAndNil(cre);
            end;
          end;
        end;
      end;
    end; // with aRouteItem do
  end; // if (aBaseNode <> nil) and...
  result:= true;
end;


function parseXMLTurn(aBaseNode : IXMLNode; aTurn : TTurn) : Boolean;
var aktNode, posNode: IXMLNode;
   tstr: String;
begin
  result:= False;
  if (aBaseNode <> nil) and (aTurn <> nil) then
  begin
    if aBaseNode.HasAttribute('duration') then
    begin
      // Mit aTurn.duration:= aBaseNode.Attributes['duration'];  geht der Dezimalpunkt verloren, weil es ein Punkt und kein Komma (=DecimalSeparator) ist!
       tstr:= aBaseNode.Attributes['duration'];
       aTurn.fduration:= StrToFloatDef(tstr, nan, HTTPMDSFormatSettings);
    end;
    if aBaseNode.HasAttribute('type') then
    begin
       tstr:= aBaseNode.Attributes['type'];
       aTurn.fturntype:= StrToTurnType(tstr);
    end;
    if aBaseNode.HasAttribute('angle') then
    begin
      // Mit aTurn.angle:= aBaseNode.Attributes['angle'];  geht der Dezimalpunkt verloren, weil es ein Punkt und kein Komma (=DecimalSeparator) ist!
      tstr:= aBaseNode.Attributes['angle'];
      aTurn.fangle:= StrToFloatDef(tstr, nan, HTTPMDSFormatSettings);
    end;
    if aBaseNode.HasAttribute('toid') then
       aTurn.ftoid:= aBaseNode.Attributes['toid'];
    if aBaseNode.HasAttribute('fromid') then
       aTurn.ffromid:= aBaseNode.Attributes['fromid'];

    posNode:= aBaseNode.ChildNodes.FindNode('position');
    if posNode <> nil
      then
      begin
        aTurn.fpos:= TGeoCoderPosition.Create;
        parseXMLPosition(posNode, aTurn.fpos);
      end;
    aktNode:= aBaseNode.ChildNodes.FindNode('command');
    if (aktNode<> nil)
      then aTurn.fcommand := aktNode.NodeValue;
    aktNode:= aBaseNode.ChildNodes.FindNode('description');
    if (aktNode<> nil)
      then aTurn.fdescription:= aktNode.NodeValue;
    result:= True;
  end; //if (aBaseNode...
end;

function parseXMLRoadElement(aBaseNode : IXMLNode; aRoadElement : TRoadElement) : Boolean;
var //cro, crost, crot : Cardinal;
    ctype : String;
    typeDataNode, aktNode, geometryNode, attributesNode, attributeNode : IXMLNode;
    aktPosition: TGeoCoderPosition;
    aktAttribute: TRouteCalculatorAttribute;
    igeometryPos,  iatt:    Integer;
begin
  result  := false;
  if (aBaseNode <> nil) and (aRoadElement <> nil) then
  begin
    ctype:= aBaseNode.Attributes['type'];
    if lowercase(ctype) = lowercase('TNaMRORoadElement') then
    begin
      typeDataNode:= aBaseNode.ChildNodes.FindNode('typedata');
      if (typeDataNode <> nil) then
      begin
        with aRoadElement do
        begin
          aktNode:= typeDataNode.ChildNodes.FindNode('ElementType');
          ElementType:= StrToRoadElementType(aktNode.Text);
          aktNode:= typeDataNode.ChildNodes.FindNode('FunctionalRoadClass');
          if (aktNode<> nil) then FunctionalRoadClass:= StrToFunctionalRoadClass(aktNode.Text);
          aktNode:= typeDataNode.ChildNodes.FindNode('ThroughTraffic');
          if (aktNode<> nil) then ThroughTraffic:= StrToBool(aktNode.Text);
          aktNode:= typeDataNode.ChildNodes.FindNode('FormOfWay');
          if (aktNode<> nil) then FormOfWay:= StrToFormOfWay(aktNode.Text);
          aktNode:= typeDataNode.ChildNodes.FindNode('BlockedPassage');
          if (aktNode<> nil) then BlockedPassage:= StrToBlockedPassage(aktNode.Text);
          aktNode:= typeDataNode.ChildNodes.FindNode('MainDirectionFlow');
          if (aktNode<> nil) then MainDirectionFlow:= StrTotMainDirectionFlow(aktNode.Text);
          aktNode:= typeDataNode.ChildNodes.FindNode('Length');
          if (aktNode<> nil) then Length:= aktNode.NodeValue;
          aktNode:= typeDataNode.ChildNodes.FindNode('ConstructionState');
          if (aktNode<> nil) then ConstructionState:= StrToConstructionState(aktNode.Text);
          aktNode:= typeDataNode.ChildNodes.FindNode('MaxSpeed');
          if (aktNode<> nil) then
          begin
            if(aktNode.Text)<> '' then MaxSpeed:= aktNode.NodeValue else MaxSpeed:= 0;
          end;
          aktNode:= typeDataNode.ChildNodes.FindNode('AverageSpeed');
          if (aktNode<> nil) then
          begin
            if (aktNode.Text <> '') then AverageSpeed:= aktNode.NodeValue else AverageSpeed:= 0;
          end;
          aktNode:= typeDataNode.ChildNodes.FindNode('StartJunctionID');
          if (aktNode<> nil) then
          begin
            if (aktNode.Text<> '') then StartJunctionID:= aktNode.NodeValue else StartJunctionID:= 0;
          end;
          aktNode:= typeDataNode.ChildNodes.FindNode('EndJunctionID');
          if (aktNode<> nil) then
          begin
            if (aktNode.Text <> '') then EndJunctionID:= aktNode.NodeValue else EndJunctionID:= 0;
          end;
          aktNode:= typeDataNode.ChildNodes.FindNode('OfficialNameID');
          if (aktNode<> nil) then
          begin
            if (aktNode.Text <> '') then OfficialNameID:= aktNode.NodeValue else OfficialNameID:=0;
          end;
          aktNode:= typeDataNode.ChildNodes.FindNode('OfficialName');
          if (aktNode<> nil) then OfficialName:= aktNode.Text;
          aktNode:= typeDataNode.ChildNodes.FindNode('RouteNumberID');
          if (aktNode<> nil) then RouteNumberID:= aktNode.NodeValue;
          aktNode:= typeDataNode.ChildNodes.FindNode('RouteNumber');
          if (aktNode<> nil) then RouteNumber:= aktNode.Text;
        end; // with aRouteItem.RoadElement do
      end else // if (typeDataNode <> nil
      begin
        exit;
      end;
      // element/geometry
      geometryNode:= aBaseNode.ChildNodes.FindNode('geometry');
      if (geometryNode <> nil) then
      begin
        for igeometryPos:= 0 to geometryNode.ChildNodes.Count-1 do
        begin
          aktPosition:= TGeoCoderPosition.Create;
          aktNode:= geometryNode.ChildNodes[igeometryPos];
          if parseXMLPosition(aktNode, aktPosition) then
          begin
            aRoadElement.fGeometry.Add(aktPosition);
          end else
          begin
            FreeAndNil(aktPosition);
          end;
        end; // for igeometryPos
      end;  // if (geometryNode <> nil)

      // element/attributes
      attributesNode:= aBaseNode.ChildNodes.FindNode('attributes');
      if (attributesNode <> nil) then
      begin
        for iatt := 0 to attributesNode.ChildNodes.Count - 1 do
        begin
          attributeNode:= attributesNode.ChildNodes[iatt];
          aktAttribute := TRouteCalculatorAttribute.Create;
          if parseXMLAttribute(attributeNode, aktAttribute) then
          begin
            aRoadElement.fAttributes.Add(aktAttribute);
          end else
          begin
            FreeAndNil(aktAttribute);
          end;
        end;
      end;   //if (attributesNode <> nil)

      result  := true;
    end;
  end;
end;

//****************************************************************************
// TRouteItem class                                                          *
//****************************************************************************
constructor TRouteItem.Create;
begin
  inherited Create;
  fElement := nil;
  fElementId  := 0;
  fElementDirection := false;
end;

destructor TRouteItem.Destroy;
begin
  FreeAndNil(fElement);
  inherited Destroy;
end;

function TRouteItem.GetToString;
begin
   Result:= 'Id= '+  IntToStr(fElementId)+  #13 +
            'Direction= ' + BoolToStr(Direction, true) + #13 +
            fElement.AsString+ #13;
end;

//****************************************************************************
// TRoadElement class                                                        *
//****************************************************************************
constructor TRoadElement.Create;
begin
  inherited Create;
  fGeometry:= THTTPMDSList.Create;
  fAttributes:= THTTPMDSList.Create;
end;

destructor TRoadElement.Destroy;
begin
  clearList(fGeometry);
  clearList(fAttributes);
  FreeAndNil(fGeometry);
  FreeAndNil(fAttributes);
  inherited Destroy;
end;

function TRoadElement.GetToString;
begin
   Result:= 'RoadElement:'+#13+ //ToDo: Bei Bedarf die fehlenden GetToString, die hier inline programmiert sind,
      // implementieren für: ElementType, FunctionalRoadClass, FormOfWay, BlockedPassage, MainDirectionFlow, ConstructionState
      Format('ElementType= %0:s', [TypInfo.GetEnumName(System.TypeInfo(TRoadType), Integer(fElementType))]) + #13+
      Format('FunctionalRoadClass= %0:s', [TypInfo.GetEnumName(System.TypeInfo(TFunctionalRoadClass), Integer(fFunctionalRoadClass))]) + #13+
     'ThroughTraffic= '+ BoolToStr(fThroughTraffic, true)+ #13 +
      Format('FormOfWay=%0:s', [TypInfo.GetEnumName(System.TypeInfo(TFormOfWay), Integer(fFormOfWay))]) + #13+
      Format('BlockedPassage=%0:s', [TypInfo.GetEnumName(System.TypeInfo(TBlockedPassage), Integer(fBlockedPassage))]) + #13+
      Format('MainDirectionFlow=%0:s', [TypInfo.GetEnumName(System.TypeInfo(TMainDirectionFlow), Integer(fMainDirectionFlow))]) + #13+
     'Length= '+  IntToStr(fLength)+  #13 +
      Format('ConstructionState=%0:s', [TypInfo.GetEnumName(System.TypeInfo(TConstructionState), Integer(fConstructionState))]) + #13+
     'MaxSpeed= ' + IntToStr(fMaxSpeed)+  #13 +
     'AverageSpeed= ' + IntToStr(fAverageSpeed)+  #13 +
     'StartJunctionID= '+ IntToStr(fStartJunctionID) +  #13 +
     'EndJunctionID= '+ IntToStr(fEndJunctionID)+  #13 +
     'OfficialNameID= '+ IntToStr(fOfficialNameID)+  #13 +
     'OfficialName= '+ fOfficialName + #13 +
     'RouteNumberID= '+ IntToStr(fRouteNumberID) +  #13 +
     'RouteNumber= '+ fRouteNumber;
end;

function TRoadElement.getPositionCount : Integer;
begin
  result  := fGeometry.Count;
end;

function TRoadElement.getPosition(index : Integer) : TGeoCoderPosition;
begin
  if (index >= 0) and (index < fGeometry.Count) then
  begin
    result  := TGeoCoderPosition(fGeometry[index]);
  end else
  begin
    result  := nil;
  end;
end;

function TRoadElement.getAttributeCount : Integer;
begin
  result  := fAttributes.Count;
end;

function TRoadElement.getAttribute(index : Integer) : TRouteCalculatorAttribute;
begin
  if (index >= 0) and (index < fAttributes.Count) then
  begin
    result  := TRouteCalculatorAttribute(fAttributes[index]);
  end else
  begin
    result  := nil;
  end;
end;


//****************************************************************************
// TAttribute class                                                          *
//****************************************************************************
constructor TRouteCalculatorAttribute.Create;
begin
  inherited Create;
  fId           := 0;
  fType         := 0;
  fTypeString   := '';
  fValue        := 0;
  fValueString  := '';
end;

destructor TRouteCalculatorAttribute.Destroy;
begin
  inherited Destroy;
end;

//****************************************************************************
// TTurn class                                                       *
//****************************************************************************
constructor TTurn.Create;
begin
  inherited Create;
end;

destructor TTurn.Destroy;
begin
  inherited Destroy;
end;

function TTurn.GetToString: String;
begin
  result:='Turn:'+ #13 +
     'duration ' + FloatToStr(fduration)+ #13 +
     Format('TurnType=%0:s', [TypInfo.GetEnumName(System.TypeInfo(TTurnType), Integer(fturntype))]) + #13+
     'angle ' +  FloatToStr(fangle)+ #13 +
     'toid ' + IntToStr(ftoid) + #13 +
     'fromid '+ IntToStr(ffromid) + #13 +
 //    'Position '+ self.fpos.AsString+ #13 +
     'command: ' + fcommand + #13 +
     'description '+ fdescription;
end;

//****************************************************************************
// TRouteCalculatorRoute class                                               *
//****************************************************************************
constructor TRouteCalculatorRoute.Create(CopyStreamOnLoad : Boolean = false);
begin
  inherited Create(CopyStreamOnLoad);
end;

destructor TRouteCalculatorRoute.Destroy;
begin
  inherited;
end;

procedure TRouteCalculatorRoute.internalLoadFromStream;
var
   cXMLdoc:    IXMLDocument;
   aktNode,
   cRootNode, cRouteNode, cRouteInfoNode,
   cRouteStartNode, cRouteDestNode,
   crouteitemsNode,
   croutePositionsNode,
   crouteguidanceNode, cTurnsNode: IXMLNode;
   cRouteGuidance: TRouteGuidance;
   errStr    : String;
   i, cRouteItemCount : Integer;
   cRoutePositionsCount : Integer;
   cTurnsCount : Integer;
begin
   cXMLDoc := NewXMLDocument('1.0');
   cXMLdoc.LoadFromStream(fFromStream);
   cRootNode := cXMLDoc.ChildNodes.FindNode('namhttpservice');
   if cRootNode = nil then
   begin
     errStr:= 'node "namhttpservice" (root) not found';
     raise EParseError.Create(errStr, fFromStream);
     exit;
   end; // aXMLDoc.IsEmptyDoc is also excluded by this way

   if cRootNode.HasAttribute('mapcid') then
   begin
     fMapCID := cRootNode.Attributes['mapcid'];
   end else
   begin
     fMapCID := -1;
   end;

   cRouteNode := cRootNode.ChildNodes.FindNode('route');
   if cRouteNode = nil then
   begin
     errStr:= '"route" node not found';
     raise EParseError.Create(errStr, fFromStream);
   end;

   // Route Info...
   cRouteInfoNode:= cRouteNode.ChildNodes.FindNode('routeinfo');
   if cRouteInfoNode = nil then
   begin
     errStr:= '"route" missing routeinfo';
     raise EParseError.Create(errStr, fFromStream);
   end;
   fMapID := cRouteInfoNode.Attributes['mapid'];
   if not TryStrToFloat(cRouteInfoNode.Attributes['duration'], fDuration, HTTPMDSFormatSettings) then
   begin
     errStr:= '"route" duration is not a number.';
     raise EParseError.Create(errStr, fFromStream);
   end;
   if not TryStrToFloat(cRouteInfoNode.Attributes['length'], fLength, HTTPMDSFormatSettings) then
   begin
     errStr:= '"route" length is not a number.';
     raise EParseError.Create(errStr, fFromStream);
   end;

   // Route Start...
   cRouteStartNode:= cRouteNode.ChildNodes.FindNode('routestart');
   if cRouteStartNode = nil then
   begin
     errStr:= '"route" missing route start node';
     raise EParseError.Create(errStr, fFromStream);
   end;
   fMatchedStartPosition := TGeoCoderPosition.Create;
   if not parseXMLPosition(
          cRouteStartNode.ChildNodes.FindNode('position'),
          fMatchedStartPosition) then
   begin
     errStr:= '"route" could not parse route start position';
     raise EParseError.Create(errStr, fFromStream);
   end;
   fRouteStartAddressEx := TRouteCalculatorAddressEx.Create;
   if not parseXMLAddressEx(cRouteStartNode.ChildNodes.FindNode('address'), fRouteStartAddressEx) then
   begin
     errStr:= '"route" could not parse route start address';
     raise EParseError.Create(errStr, fFromStream);
   end;

   // Route Destination...
   cRouteDestNode:= cRouteNode.ChildNodes.FindNode('routedestination');
   if cRouteDestNode = nil then
   begin
     errStr:= '"route" missing route destination node';
     raise EParseError.Create(errStr, fFromStream);
   end;
   fMatchedDestinationPosition := TGeoCoderPosition.Create;
   if not parseXMLPosition(cRouteDestNode.ChildNodes.FindNode('position'), fMatchedDestinationPosition) then
   begin
     errStr:= '"route" could not parse route destination position';
     raise EParseError.Create(errStr, fFromStream);
   end;
   fRouteDestinationAddressEx := TRouteCalculatorAddressEx.Create;
   if not parseXMLAddressEx(cRouteDestNode.ChildNodes.FindNode('address'), fRouteDestinationAddressEx) then
   begin
     errStr:= '"route" could not parse route destination address';
     raise EParseError.Create(errStr, fFromStream);
   end;

   // Route Items...
   cRouteItemsNode:= cRouteNode.ChildNodes.FindNode('routeitems');
   if crouteitemsNode <> nil then
   begin
     cRouteItemCount := crouteitemsNode.ChildNodes.Count; // Anzahl 'routeitem' nodes
     // die leeren 'routeitem' nodes löschen, die durch Leerzeilen im xml entstanden sind
     for i :=  pred(cRouteItemCount) downto 0 do
     begin
       if not (crouteitemsNode.ChildNodes[i].HasChildNodes)
       then crouteitemsNode.ChildNodes.Delete(i);
     end;
     cRouteItemCount := crouteitemsNode.ChildNodes.Count;
     setlength(fRouteItems, cRouteItemCount);
     for i := 0 to pred(cRouteItemCount) do
       begin
         fRouteItems[i] := TRouteItem.Create;
         aktNode:= crouteitemsNode.ChildNodes.Get(i);
         // get direction and element of RouteItem
         if aktNode.HasAttribute('direction')
           then fRouteItems[i].Direction:= aktNode.Attributes['direction'];
         if aktNode.HasAttribute('element')
           then fRouteItems[i].fElementId:= aktNode.Attributes['element'];
         try
         if not parseXMLRouteItem(aktNode, fRouteItems[i]) then
           begin
             errStr:= '"route" could not parse route item['+IntToStr(i)+']';
             raise EParseError.Create(errStr, fFromStream);
           end;
         except
            errStr:= '"route" could not parse route item['+IntToStr(i)+']';
            raise EParseError.Create(errStr, fFromStream);
         end;
       end; // for i
   end; // if crouteitemsNode <> nil

   // Positions...
   cRoutePositionsNode:= cRouteNode.ChildNodes.FindNode('positions');
   if cRoutePositionsNode <> nil then
   begin
     cRoutePositionsCount := cRoutePositionsNode.ChildNodes.Count;
     // leere 'position' nodes gibt es hier nicht --> nichts zu löschen
     setlength(fRoutePositions, cRoutePositionsCount);
     for i := 0 to pred(cRoutePositionsCount) do
     begin
       fRoutePositions[i] := TGeoCoderPosition.Create;
       if not parseXMLPosition(cRoutePositionsNode.ChildNodes.Get(i), fRoutePositions[i]) then
       begin
         errStr:= '"route" could not parse route position['+IntToStr(i)+']';
         raise EParseError.Create(errStr, fFromStream);
       end;
     end;
   end;

   // Route Guidance...
   cRouteGuidance:= TRouteGuidance.Create;
   cRouteGuidanceNode:= cRouteNode.ChildNodes.FindNode('routeguidance');
   if cRouteGuidanceNode <> nil then
   begin
     if crouteguidanceNode.HasAttribute('duration')
        then cRouteGuidance.duration:= crouteguidanceNode.Attributes['duration'];
     if crouteguidanceNode.HasAttribute('length')
        then cRouteGuidance.length:= crouteguidanceNode.Attributes['length'];
     if crouteguidanceNode.HasAttribute('name')
        then cRouteGuidance.name:= crouteguidanceNode.Attributes['name'];

     cTurnsNode := cRouteGuidanceNode.ChildNodes.FindNode('turns');
     if cTurnsNode <> nil then
     begin
       cTurnsCount := cTurnsNode.ChildNodes.Count;
       // die leeren 'turns'- ChildNodes löschen, die durch Leerzeilen im xml entstanden sind
       for i :=  pred(cTurnsCount) downto 0 do
       begin
         if not (cTurnsNode.ChildNodes[i].HasChildNodes)
         then cTurnsNode.ChildNodes.Delete(i);
       end;
       cTurnsCount := cTurnsNode.ChildNodes.Count;
       setlength(fRouteTurns, cTurnsCount);
       for i := 0 to pred(cTurnsCount) do
       begin
         fRouteTurns[i] := TTurn.Create;
         aktNode:= cTurnsNode.ChildNodes.get(i);
         if not parseXMLTurn(aktNode, fRouteTurns[i]) then
         begin
           errStr:= '"route" could not parse turn['+IntToStr(i)+']';
           raise EParseError.Create(errStr, fFromStream);
         end; // if not parseXMLTurn
       end; // for i
     end; // if cTurnsNode <> nil
   end; // if cRouteGuidanceNode <> nil
end; // procedure TRouteCalculatorRoute.loadFromStream

function TRouteCalculatorRoute.getRouteItem(index: Integer): TRouteItem;
begin
  Result:= nil;
  if (index >=0) and (index <= Length(fRouteItems))
    then Result:= fRouteItems[index];
end;

function TRouteCalculatorRoute.getRouteItemsCount: Integer;
begin
  Result:= Length(fRouteItems);
end;

function TRouteCalculatorRoute.getRouteTurnsCount: Integer;
begin
  Result:= Length(fRouteTurns);
end;

function TRouteCalculatorRoute.getPositionsCount: Integer;
begin
   Result:= Length(fRoutePositions);
end;

function TRouteCalculatorRoute.GetPosition(index: Integer): TGeoCoderPosition;
begin
   Result:= fRoutePositions[index];
end;

function TRouteCalculatorRoute.getToString: String;
begin
   Result:= ' Route: ' + #13 +
      'MapCID= '+  IntToStr(fMapCID)+ #13 +
      'MapID= ' + fMapID + #13 +
      'Duration= ' + FloatToStr(fDuration) +  #13 +
      'Length= ' + FloatToStr(fLength) +  #13 +
      IntToStr(RouteItemCount)+ ' RouteItems'+  #13+
      IntToStr(PositionCount)+ ' RoutePositions'+  #13+
      IntToStr(TurnCount) +' Turns';
end;

function TRouteCalculatorRoute.GetTurn(index: Integer): TTurn;
begin
   Result:= nil;
   if(index >=0 ) and (index < Length(fRouteTurns))
   then begin
     Result:= fRouteTurns[index];
   end;
end;

//****************************************************************************
// TRouteCalculator class                                                    *
//****************************************************************************

constructor TRouteCalculator.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TRouteCalculator.Destroy;
begin
  inherited Destroy;
end;

//****************************************************************************
// TRouteCalculatorHTTP class                                                *
//****************************************************************************

function TRouteCalculatorHTTP.calculateRouteByGeoPositions(
      const aMapId : Integer; const aStartLon, aStartLat, aDestinationLon, aDestinationLat : Double;
      const aRouteType : TRouteType; const aRoutePrecision : Double = 1.6;
      aDetailPositions : Boolean = true; aDetailItems : Boolean = true; aDetailTurns : Boolean = true
    ): TRouteCalculatorRoute;
var params : THTTPConnectorParams;
    ms : TStream;
    dtl : String;
begin
  if fHTTP = nil then
  begin
    raise EHTTPError.Create('can not perform action if http connector ist not assigned!');
  end;

  params := fHTTP.createParams;
  try
    if aDetailPositions and aDetailItems and aDetailTurns then
    begin
      dtl := 'all';
    end else
    begin
      dtl := '';
      if aDetailPositions then begin if dtl <> '' then dtl := dtl + ','; dtl := dtl + 'positions'; end;
      if aDetailItems then begin if dtl <> '' then dtl := dtl + ','; dtl := dtl + 'items'; end;
      if aDetailTurns then begin if dtl <> '' then dtl := dtl + ','; dtl := dtl + 'turns'; end;
    end;
    params.addFloat('routeprecision', aRoutePrecision);
    if (aRouteType =  RT_SHORTEST) then
    begin
      params.addString('routetype','shortest');
    end else
    begin
      if (aRouteType =  RT_FASTEST) then
      begin
        params.addString('routetype','fastest');
      end;
    end;
    params.addInteger('mapcid', amapid);
    params.addFloat('startlongitude', aStartLon);
    params.addFloat('startlatitude', aStartLat);
    params.addFloat('destinationlongitude', aDestinationLon);
    params.addFloat('destinationlatitude', aDestinationLat);

    params.addString('outdtl', dtl);
    params.addString('outfmt', 'xml');

    ms  := fHTTP.getStream('/calculateroutebygeopositions', params);
    try
      result := TRouteCalculatorRoute.Create;
      try
        result.loadFromStream(ms);
      except
        on e : exception do
        begin
          result.FreeStream := true;
          FreeAndNil(result);
          raise e;
        end;
      end;
    finally
      if result.CopyStream then
      begin
        FreeAndNil(ms);
      end;
    end;
  finally
    FreeAndNil(params);
  end;
end;

function TRouteCalculatorHTTP.findRouteByGeoPositions(const aMapId : Integer; const asourcestream : TStream;
      alookahead : Integer = 2; awayforms : String = ''; aDetailPositions : Boolean = true; aDetailItems : Boolean = true; aDetailTurns : Boolean = true
      ) : TRouteCalculatorRoute;
var params : THTTPConnectorParams;
    ms : TStream;
    dtl : String;
begin
  if fHTTP = nil then
  begin
    raise EHTTPError.Create('can not perform action if http connector ist not assigned!');
  end;

  params := fHTTP.createParams;
  try
    if aDetailPositions and aDetailItems and aDetailTurns then
    begin
      dtl := 'all';
    end else
    begin
      dtl := '';
      if aDetailPositions then begin if dtl <> '' then dtl := dtl + ','; dtl := dtl + 'positions'; end;
      if aDetailItems then begin if dtl <> '' then dtl := dtl + ','; dtl := dtl + 'items'; end;
      if aDetailTurns then begin if dtl <> '' then dtl := dtl + ','; dtl := dtl + 'turns'; end;
    end;
    params.addInteger('lookahead', alookahead);
    params.addInteger('mapcid', amapid);
    if awayforms <> '' then
    begin
      params.addString('wayforms', awayforms);
    end;

    params.addString('outdtl', dtl);
    params.addString('outfmt', 'xml');

    ms  := fHTTP.postStream('/findroutebygeopositions', params, asourcestream);
    try
      result := TRouteCalculatorRoute.Create;
      try
        result.loadFromStream(ms);
      except
        on e : exception do
        begin
          result.FreeStream := true;
          FreeAndNil(result);
          raise e;
        end;
      end;
    finally
      if result.CopyStream then
      begin
        FreeAndNil(ms);
      end;
    end;
  finally
    FreeAndNil(params);
  end;
end;

function TRouteCalculatorHTTP.calculateRouteByGeoPositions(aResultToStream : TStream; const aMapId : Integer; const aStartLon, aStartLat, aDestinationLon, aDestinationLat : Double;
      const aRouteType : TRouteType; const aRoutePrecision : Double = 1.6;
      aDetailPositions : Boolean = true; aDetailItems : Boolean = true; aDetailTurns : Boolean = true
      ): TRouteCalculatorRoute;
var params : THTTPConnectorParams;
    dtl : String;
begin
  if fHTTP = nil then
  begin
    raise EHTTPError.Create('can not perform action if http connector ist not assigned!');
  end;

  params := fHTTP.createParams;
  try
    if aDetailPositions and aDetailItems and aDetailTurns then
    begin
      dtl := 'all';
    end else
    begin
      dtl := '';
      if aDetailPositions then begin if dtl <> '' then dtl := dtl + ','; dtl := dtl + 'positions'; end;
      if aDetailItems then begin if dtl <> '' then dtl := dtl + ','; dtl := dtl + 'items'; end;
      if aDetailTurns then begin if dtl <> '' then dtl := dtl + ','; dtl := dtl + 'turns'; end;
    end;
    params.addFloat('routeprecision', aRoutePrecision);
    if (aRouteType =  RT_SHORTEST) then
    begin
      params.addString('routetype','shortest');
    end else
    begin
      if (aRouteType =  RT_FASTEST) then
      begin
        params.addString('routetype','fastest');
      end;
    end;
    params.addInteger('mapcid', amapid);
    params.addFloat('startlongitude', aStartLon);
    params.addFloat('startlatitude', aStartLat);
    params.addFloat('destinationlongitude', aDestinationLon);
    params.addFloat('destinationlatitude', aDestinationLat);

    params.addString('outdtl', dtl);
    params.addString('outfmt', 'xml');

    if fHTTP.get('/calculateroutebygeopositions', params, aResultToStream) then
    begin
      try
        result := TRouteCalculatorRoute.Create;
        try
          result.loadFromStream(aResultToStream);
        except
          on e : exception do
          begin
            result.FreeStream := false;
            FreeAndNil(result);
            raise e;
          end;
        end;
      finally
        
      end;
    end else
    begin
      raise EHTTPError.Create('get for "/calculateroutebygeopositions" simply failed.');
    end;
  finally
    FreeAndNil(params);
  end;
end;

function TRouteCalculatorHTTP.findRouteByGeoPositions(aResultToStream : TStream; const aMapId : Integer; const asourcestream : TStream;
  alookahead : Integer = 2; awayforms : String = ''; aDetailPositions : Boolean = true; aDetailItems : Boolean = true; aDetailTurns : Boolean = true
  ) : TRouteCalculatorRoute;
var params : THTTPConnectorParams;
    dtl : String;
begin
  if fHTTP = nil then
  begin
    raise EHTTPError.Create('can not perform action if http connector ist not assigned!');
  end;

  params := fHTTP.createParams;
  try
    if aDetailPositions and aDetailItems and aDetailTurns then
    begin
      dtl := 'all';
    end else
    begin
      dtl := '';
      if aDetailPositions then begin if dtl <> '' then dtl := dtl + ','; dtl := dtl + 'positions'; end;
      if aDetailItems then begin if dtl <> '' then dtl := dtl + ','; dtl := dtl + 'items'; end;
      if aDetailTurns then begin if dtl <> '' then dtl := dtl + ','; dtl := dtl + 'turns'; end;
    end;
    params.addInteger('lookahead', alookahead);
    params.addInteger('mapcid', amapid);
    if awayforms <> '' then
    begin
      params.addString('wayforms', awayforms);
    end;

    params.addString('outdtl', dtl);
    params.addString('outfmt', 'xml');

    if fHTTP.post('/findroutebygeopositions', params, asourcestream, aResultToStream) then
    begin
      try
        result := TRouteCalculatorRoute.Create;
        try
          result.loadFromStream(aResultToStream);
        except
          on e : exception do
          begin
            result.FreeStream := false;
            FreeAndNil(result);
            raise e;
          end;
        end;
      finally
        
      end;
    end else
    begin
      raise EHTTPError.Create('get for "/findroutebygeopositions" simply failed.');
    end;
  finally
    FreeAndNil(params);
  end;
end;

constructor TRouteCalculatorHTTP.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fHTTP := nil;
end;

destructor TRouteCalculatorHTTP.Destroy;
begin
  fHTTP  := nil;
  inherited Destroy;
end;


end.
