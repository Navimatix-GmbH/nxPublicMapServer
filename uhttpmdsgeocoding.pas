unit uhttpmdsgeocoding;

interface

uses types, classes, SysUtils, IdHTTP, XMLIntf, XMLDoc, uhttpmdsbase;

type
  // Exception
  EHTTPCode = class (Exception)
  private
    fResponseCode : Integer;
  public
    constructor Create(ErrorMessage : String; responseCode : Integer);
    property ResponseCode : Integer read fResponseCode;
  end;

  EGeoCoder = class(Exception)
  private
    fResultText : String;
  public
    constructor Create(ErrorMessage : String; aResultText : String);
    property ResultText  : String read fResultText;
  end;

  // Data Structures
  TGeoCoderPosition = class
  private
    fLongitude  : double;
    fLatitude   : double;
    fMapCID     : Integer;
  protected
    //procedure parseXMLPosition(aBaseNode : IXMLNode); virtual;
  public
    constructor Create; overload;
    constructor Create(aLongitude, aLatitude : Double; aMapCID : Integer); overload;
    destructor  Destroy; override;
    procedure parseXMLPosition(aBaseNode : IXMLNode); virtual;  // war protected

    procedure loadFromStream(aFromStream : TStream); virtual;

    property Longitude  : double read fLongitude write fLongitude;
    property Latitude   : double read fLatitude write fLatitude;
    property MapCID     : Integer read fMapCID write fMapCID;
  end;

  TGeoCoderAddress = class
  private
    fMapCID           : Integer;
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
    fLanguage         : String;
  protected
    procedure parseXMLAddress(aBaseNode : IXMLNode); virtual;
  public
    constructor Create; overload;
    constructor Create (aCountry, aCountryPart, aCountryDistrict, aCountryCode, aCity, aCityPart,
                        aStreet, aHouse, aZipCode, aBuilding : String; aMapCID : Integer); overload;
    destructor  Destroy; override;

    procedure invalidateAddress; virtual;
    procedure loadFromStream(aFromStream : TStream); virtual;

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
    property Language         : String read fLanguage write fLanguage;
  end;

  TGeoCoderAddressEx = class (TGeoCoderAddress)
  private
    fAdminId         : Cardinal;
    fStreetId        : Cardinal;
    fRoadElementId   : Cardinal;
    fAdminName       : String;
    fAdminOrder      : String;
    fStreetName      : String;
    fRoadElementPos  : Double;
    fLongitude       : Double;
    fLatitude        : Double;
    fIsMotorway      : Boolean;
    fMatchingSide    : String;
    fMatchingQuality : Double;
    fMatchingDirection : String;
    fMatchingType    : String;
    fMatchedElementDistance : Double;
    fMatchedElementAngle : Double;
  protected
    procedure parseXMLAddress(aBaseNode : IXMLNode); override;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure invalidateAddress; override;

    property AdminId          : Cardinal read fAdminId write fAdminId;
    property StreetId         : Cardinal read fStreetId write fStreetId;
    property RoadElementId    : Cardinal read fRoadElementId write fRoadElementId;
    property AdminName        : String read fAdminName write fAdminName;
    property AdminOrder       : String read fAdminOrder write fAdminOrder;
    property StreetName       : String read fStreetName write fStreetName;
    property RoadElementPos   : Double read fRoadElementPos write fRoadElementPos;
    property Longitude        : Double read fLongitude write fLongitude;
    property Latitude         : Double read fLatitude write fLatitude;
    property IsMotorway       : Boolean read fIsMotorway write fIsMotorway;
    property MatchingSide     : String read fMatchingSide write fMatchingSide;
    property MatchingQuality  : Double read fMatchingQuality write fMatchingQuality;
    property MatchingDirection      : String read fMatchingDirection write fMatchingDirection;
    property MatchingType     : String read fMatchingType write fMatchingType;
    property MatchedElementDistance : Double read fMatchedElementDistance write fMatchedElementDistance;
    property MatchedElementAngle    : Double read fMatchedElementAngle write fMatchedElementAngle;
  end;

  TGeoCoderAddressInfo = class
  private
    fAddress           : TGeoCoderAddress;
    fPosition          : TGeoCoderPosition;
  public
    constructor Create; overload;
    constructor Create( aAddress : TGeoCoderAddress; aPosition : TGeoCoderPosition); overload;
    destructor  Destroy; override;

    procedure loadFromStream(aFromStream : TStream); virtual;

    class function format(const aAddressInfo : TGeoCoderAddressInfo) : String;
    class procedure parseXMLaddressInfo(aRootNode : IXMLNode; resultAddress : TGeoCoderAddress; resultPosition : TGeoCoderPosition);
    class function loadFromStreamToList(const aFromStream : TStream; aToList : THTTPMDSList) : Boolean;

    property Address   : TGeoCoderAddress read fAddress write fAddress;
    property Position  : TGeoCoderPosition read fPosition write fPosition;
  end;

  // Geo Coder
  TGeoCoder = class(TComponent)
  public
    function getGeoPositionByAddress(const aAddress: TGeoCoderAddress): TGeoCoderPosition; overload; virtual; abstract;
    function getGeoPositionByAddress(const aAddress: TGeoCoderAddress; aStream : TStream): TGeoCoderPosition; overload; virtual; abstract;

    function getAddressByGeoPosition(const aPosition: TGeoCoderPosition): TGeoCoderAddress; overload; virtual; abstract;
    function getAddressByGeoPosition(const aPosition: TGeoCoderPosition; aStream : TStream): TGeoCoderAddress; overload; virtual; abstract;

    function getAddressData (const aAddress: TGeoCoderAddress): TGeoCoderAddressEx; overload; virtual; abstract;
    function getAddressData (const aAddress: TGeoCoderAddress; aStream : TStream) : TGeoCoderAddressEx; overload; virtual; abstract;

    function identifyAddressSet (const aAddress: TGeoCoderAddress; aToList: THTTPMDSList): Boolean; overload; virtual; abstract;
    function identifyAddressSet (const aAddress: TGeoCoderAddress; aToList: THTTPMDSList; aStream : TStream): Boolean; overload; virtual; abstract;

    function getAddressSet (const aSearchText: String; const aMapCID : Integer; aToList: THTTPMDSList): Boolean; overload; virtual; abstract;
    function getAddressSet (const aSearchText: String; const aMapCID : Integer; aToList: THTTPMDSList; aStream: TStream): Boolean; overload; virtual; abstract;
  end;

  TGeoCoderHTTP = class (TGeoCoder)
  private
    fHTTP                 : THTTPConnector;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

    function getGeoPositionByAddress(const aAddress: TGeoCoderAddress; aStream : TStream): TGeoCoderPosition; overload; override;
    function getGeoPositionByAddress(const aAddress: TGeoCoderAddress): TGeoCoderPosition; overload; override;

    function getAddressByGeoPosition(const aPosition: TGeoCoderPosition; aStream : TStream): TGeoCoderAddress; overload; override;
    function getAddressByGeoPosition(const aPosition: TGeoCoderPosition): TGeoCoderAddress; overload; override;

    function getAddressSet (const aSearchText: String; const aMapCID : Integer; aToList: THTTPMDSList; aStream: TStream): Boolean; overload; override;
    function getAddressSet (const aSearchText: String; const aMapCID : Integer; aToList: THTTPMDSList): Boolean; overload; override;

    function getAddressData (const aAddress: TGeoCoderAddress; aStream : TStream) : TGeoCoderAddressEx; overload; override;
    function getAddressData (const aAddress: TGeoCoderAddress): TGeoCoderAddressEx; overload; override;

    function identifyAddressSet (const aAddress: TGeoCoderAddress; aToList: THTTPMDSList; aStream : TStream): Boolean; overload; override;
    function identifyAddressSet (const aAddress: TGeoCoderAddress; aToList: THTTPMDSList): Boolean; overload; override;

  published
    property HTTP : THTTPConnector read fHTTP write fHTTP;
  end;



implementation

uses Math;

{ **************************************************************************** }
{ ***** FormatSettings ******************************************************* }
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
{ ***** EHTTPCode ************************************************************ }
{ **************************************************************************** }

constructor EHTTPCode.Create(ErrorMessage : String; responseCode : Integer);
begin
  inherited Create(ErrorMessage);
  fResponseCode := responseCode;
end;

{ **************************************************************************** }
{ ***** EHTTPCode ************************************************************ }
{ **************************************************************************** }
constructor EGeoCoder.Create(ErrorMessage : String; aResultText : String);
begin
  inherited Create(ErrorMessage);
  fResultText := aResultText;
end;


{ **************************************************************************** }
{ ***** TGeoCoderPosition **************************************************** }
{ **************************************************************************** }

constructor TGeoCoderPosition.Create;
begin
  inherited Create;
  fLongitude := nan;
  fLatitude := nan;
  fMapCID := -1;
end;

constructor TGeoCoderPosition.Create(aLongitude, aLatitude : Double; aMapCID : Integer);
begin
  self.Create;
  fLongitude  := aLongitude;
  fLatitude   := aLatitude;
  fMapCID     := aMapCID;
end;

destructor TGeoCoderPosition.Destroy;
begin
  inherited Destroy;
end;

procedure TGeoCoderPosition.loadFromStream(aFromStream : TStream);
var cXMLdoc   : IXMLDocument;
    cRootNode,
    cNode     : IXMLNode;
begin
  cXMLDoc := XMLDoc.NewXMLDocument('1.0');
  try
    try
      cXMLDoc.LoadFromStream(aFromStream);
    except
      on e : exception do
      begin
        raise Exception.Create('Loading XML from Stream failed: ' + e.Message);
      end;
    end;
    cRootNode := cXMLDoc.ChildNodes.FindNode('namhttpservice');
    if cRootNode <> nil then
    begin
      cNode     := cRootNode.ChildNodes.FindNode('geoposition');
      if cNode <> nil then
      begin
        try
          parseXMLPosition(cNode);
        except
          on e : Exception do
          begin
            raise Exception.Create('XML-Parser failed: ' + e.Message);
          end;
        end;
      end else
      begin
        raise Exception.Create('no position available');
      end;
    end else
    begin
      cRootNode := cRootNode.ChildNodes.FindNode('error');
      raise Exception.Create('no service available');
    end;
  finally
    cXMLDoc := nil;
  end;
end;

procedure TGeoCoderPosition.parseXMLPosition(aBaseNode: IXMLNode);
var
  clon, clat : string;
begin
  if aBaseNode <> nil then
  begin
    if aBaseNode.ParentNode <> nil then
    begin
      if aBaseNode.ParentNode.HasAttribute('mapcid')
        then fMapCID := StrToIntDef(aBaseNode.ParentNode.Attributes['mapcid'], -1)
        else fMapCID := -1;
    end;

    if aBaseNode.HasAttribute('longitude') then
    begin
      clon := aBaseNode.Attributes['longitude'];
      fLongitude := StrToFloatDef(clon, nan, MapServerFS);
    end;
    if aBaseNode.HasAttribute('latitude') then
    begin
      clat := aBaseNode.Attributes['latitude'];
      fLatitude := StrToFloatDef(clat, nan, MapServerFS);
    end;
  end else
  begin
    raise Exception.Create('rootNode is nil');
  end;
end;


{ **************************************************************************** }
{ ***** TGeoCoderAddress ***************************************************** }
{ **************************************************************************** }

constructor TGeoCoderAddress.Create;
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

constructor TGeoCoderAddress.Create(aCountry, aCountryPart, aCountryDistrict, aCountryCode, aCity,
                                     aCityPart, aStreet, aHouse, aZipCode, aBuilding: string; aMapCID : Integer);
begin
  self.Create;
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


destructor TGeoCoderAddress.Destroy;
begin
  inherited Destroy;
end;

procedure TGeoCoderAddress.loadFromStream(aFromStream : TStream);
var cXMLdoc   : IXMLDocument;
    cRootNode,
    cNode     : IXMLNode;
begin
  cXMLDoc := XMLDoc.NewXMLDocument('1.0');
  try
    try
      cXMLDoc.LoadFromStream(aFromStream);
    except
      on e : exception do
      begin
        raise Exception.Create('Loading XML from Stream failed: ' + e.Message);
      end;
    end;
    cRootNode := cXMLDoc.ChildNodes.FindNode('namhttpservice');
    if cRootNode <> nil then
    begin
      cNode     := cRootNode.ChildNodes.FindNode('address');
      if cNode <> nil then
      begin
        try
          parseXMLAddress(cNode);
        except
          on e : Exception do
          begin
            raise Exception.Create('XML-Parser failed: ' + e.Message);
          end;
        end;
      end else
      begin
        raise Exception.Create('no address available');
      end;
    end else
    begin
      cRootNode := cRootNode.ChildNodes.FindNode('error');
      raise Exception.Create('no service available');
    end;
  finally
    cXMLDoc := nil;
  end;
end;

procedure TGeoCoderAddress.invalidateAddress;
begin
  fCountry          := '';
  fCountryPart      := '';
  fCountryDistrict  := '';
  fCity             := '';
  fCityPart         := '';
  fStreet           := '';
  fHouse            := '';
  fZipCode          := '';
end;

procedure TGeoCoderAddress.parseXMLAddress(aBaseNode : IXMLNode);
var
  clon, clat : string;
begin
  invalidateAddress;

  if aBaseNode <> nil then
  begin
    if aBaseNode.ParentNode <> nil then
    begin
      fMapCid          := StrToIntDef(aBaseNode.ParentNode.Attributes['mapcid'], -1);
    end;

    fCountry         := aBaseNode.Attributes['country'];
    fCountryCode     := aBaseNode.Attributes['countrycode'];
    fCountryPart     := aBaseNode.Attributes['countrypart'];
    fCountryDistrict := aBaseNode.Attributes['countrydistrict'];
    fCity            := aBaseNode.Attributes['city'];
    fCityPart        := aBaseNode.Attributes['citypart'];
    fStreet          := aBaseNode.Attributes['street'];
    fHouse           := aBaseNode.Attributes['house'];
    fZipCode         := aBaseNode.Attributes['zipcode'];
    fBuilding        := aBaseNode.Attributes['building'];
    if aBaseNode.HasAttribute('language') then
      fLanguage := aBaseNode.Attributes['language'];

  end else
  begin
    raise Exception.Create('rootNode is nil');
  end;
end;


{ **************************************************************************** }
{ ***** TGeoCoderAddressEx *************************************************** }
{ **************************************************************************** }

constructor TGeoCoderAddressEx.Create;
begin
  inherited Create;
  fAdminId         := 0;
  fStreetId        := 0;
  fRoadElementId   := 0;
  fAdminName       := '';
  fAdminOrder      := '';
  fStreetName      := '';
  fRoadElementPos  := nan;
  fLongitude       := nan;
  fLatitude        := nan;
  fIsMotorway      := false;
  fMatchingSide    := '';
  fMatchingQuality := nan;
  fMatchingDirection := '';
  fMatchingType    := '';
  fMatchedElementDistance := nan;
  fMatchedElementAngle := nan;
end;

destructor TGeoCoderAddressEx.Destroy;
begin
  inherited Destroy;
end;

procedure TGeoCoderAddressEx.invalidateAddress;
begin
  inherited invalidateAddress;
  fAdminId       := 0;
  fStreetId      := 0;
  fRoadElementId := 0;
  fLanguage       := '';
  fAdminName      := '';
  fAdminOrder     := '';
  fStreetName     := '';
  fRoadElementPos := nan;
  fLongitude      := nan;
  fLatitude       := nan;
  fIsMotorway     := false;
end;

procedure TGeoCoderAddressEx.parseXMLAddress(aBaseNode : IXMLNode);

begin
  if aBaseNode <> nil then
  begin
    inherited parseXMLAddress(aBaseNode);
    if aBaseNode.HasAttribute('administrationid') then
      fAdminID := aBaseNode.Attributes['administrationid'];
    if aBaseNode.HasAttribute('streetid') then
      fStreetId := aBaseNode.Attributes['streetid'];
    if aBaseNode.HasAttribute('roadelementid') then
      fRoadElementId := aBaseNode.Attributes['roadelementid'];

    if aBaseNode.HasAttribute('administrationname') then
      fAdminName := aBaseNode.Attributes['administrationname'];
    if aBaseNode.HasAttribute('administrationorder') then
      fAdminOrder := aBaseNode.Attributes['administrationorder'];

    if aBaseNode.HasAttribute('streetname') then
      fStreetName := aBaseNode.Attributes['streetname'];
    if aBaseNode.HasAttribute('roadelementpos') then
    begin
      fRoadElementPos := StrToFloatDef(aBaseNode.Attributes['roadelementpos'], nan, MapServerFS);
    end;
    if aBaseNode.HasAttribute('longitude') then
    begin
      fLongitude := StrToFloatDef(aBaseNode.Attributes['longitude'], nan, MapServerFS);
    end;
    if aBaseNode.HasAttribute('latitude') then
    begin
      fLatitude := StrToFloatDef(aBaseNode.Attributes['latitude'], nan, MapServerFS);
    end;
    if aBaseNode.HasAttribute('ismotorway') then
    begin
      fIsMotorway := StrToBoolDef(aBaseNode.Attributes['ismotorway'], false);
    end;
    if aBaseNode.HasAttribute('matchingside') then
    begin
      fMatchingSide := aBaseNode.Attributes['matchingside'];
    end;
    if aBaseNode.HasAttribute('matchingquality') then
    begin
      fMatchingQuality := StrToFloatDef(aBaseNode.Attributes['matchingquality'], nan, MapServerFS);
    end;
    if aBaseNode.HasAttribute('matchingdirection') then
    begin
      fMatchingDirection := aBaseNode.Attributes['matchingdirection'];
    end;
    if aBaseNode.HasAttribute('matchingtype') then
    begin
      fMatchingType := aBaseNode.Attributes['matchingtype'];
    end;
    if aBaseNode.HasAttribute('matchedelementdistance') then
    begin
      MatchedElementDistance := StrToFloatDef(aBaseNode.Attributes['matchedelementdistance'], nan, MapServerFS);
    end;
    if aBaseNode.HasAttribute('matchedelementangle') then
    begin
      MatchedElementAngle := StrToFloatDef(aBaseNode.Attributes['matchedelementangle'], nan, MapServerFS);
    end;

  end else
  begin
    raise Exception.Create('rootNode is nil');
  end;
end;


{ **************************************************************************** }
{ ***** TGeoCoderAddressInfo ************************************************* }
{ **************************************************************************** }

constructor TGeoCoderAddressInfo.Create;
begin
  inherited Create;
  fAddress := nil;
  fPosition := nil;
end;

constructor TGeoCoderAddressInfo.Create(aAddress : TGeoCoderAddress;
                                          aPosition : TGeoCoderPosition);
begin
  self.Create;
  fAddress := aAddress;
  fPosition := aPosition;
end;

destructor TGeoCoderAddressInfo.Destroy;
begin
  FreeAndNil(fAddress);
  FreeAndNil(fPosition);
  inherited Destroy;
end;

procedure TGeoCoderAddressInfo.loadFromStream(aFromStream : TStream);
var cXMLdoc   : IXMLDocument;
    cRootNode : IXMLNode;
    cNode     : IXMLNode;
begin
  cXMLDoc := XMLDoc.NewXMLDocument('1.0');
  try
    try
      cXMLDoc.LoadFromStream(aFromStream);
    except
      on e : exception do
      begin
        raise Exception.Create('Loading XML from Stream failed: ' + e.Message);
      end;
    end;
    cRootNode := cXMLDoc.ChildNodes.FindNode('namhttpservice');
    if cRootNode <> nil then
    begin
      cNode     := cRootNode.ChildNodes.FindNode('address');
      if cNode <> nil then
      begin
        try
          if self.fAddress = nil then
          begin
            self.fAddress := TGeoCoderAddressEx.Create;
          end;
          if self.fPosition = nil then
          begin
            self.fPosition  := TGeoCoderPosition.Create;
          end;
          self.parseXMLaddressInfo(cNode, self.fAddress, self.fPosition);
        except
          on e : Exception do
          begin
            raise Exception.Create('XML-Parser failed: ' + e.Message);
          end;
        end;
      end else
      begin
        raise Exception.Create('no address available');
      end;
    end else
    begin
      cRootNode := cRootNode.ChildNodes.FindNode('error');
      raise Exception.Create('no service available');
    end;
  finally
    cXMLDoc := nil;
  end;
end;

class function TGeoCoderAddressInfo.format(const aAddressInfo : TGeoCoderAddressInfo) : String;
var cStr : String;
const LF = #13#10;
begin
  cStr := '';

  with (aAddressInfo.Address) do
  begin
    cStr := Country;

    if CountryPart <> '' then
      cStr := cStr + ',  ' + CountryPart;
    if CountryDistrict <> '' then
      cStr := cStr + ',  ' + CountryDistrict;

    cStr := cStr + LF + City;

    if CityPart <> '' then
      cStr := cStr + ',  ' + CityPart;
    if ZipCode <> '' then
      cStr := cStr + ',  ' + ZipCode;

    if Street <> '' then
      cStr :=  LF + cStr + Street;
    if House <> '' then
      cStr := cStr + ',  ' + House;
    if Building <> '' then
      cStr := cStr + ',  ' + Building;

    cStr := cStr + LF + LF;
  end;

  if (aAddressInfo.Address is TGeoCoderAddressEx) then
    with (aAddressInfo.Address as TGeoCoderAddressEx) do
    begin
      cStr := cStr + 'AdminId: ' + InttoStr(AdminId) + LF;
      cStr := cStr + 'StreetId: ' + IntToStr(StreetId) + LF;
      cStr := cStr + 'RoadElementId: ' + IntToStr(RoadElementId) + LF + LF;
    end;

  with (aAddressInfo.Position) do
  begin
    cStr := cStr + 'Longitude: ' + FloatToStr(Longitude) + LF;
    cStr := cStr + 'Latitude: ' + FloatToStr(Latitude);
  end;

  result := cStr;
end;

class function TGeoCoderAddressInfo.loadFromStreamToList(const aFromStream : TStream; aToList : THTTPMDSList) : Boolean;
var
  cXMLdoc           : IXMLDocument;
  cRootNode,
  cNode             : IXMLNode;
  cnt,i             : Integer;
  resultPosition    : TGeoCoderPosition;
  resultAddress     : TGeoCoderAddress;
  resultAddressInfo : TGeoCoderAddressInfo;
  cResultText       : String;

begin
  try
    cXMLDoc := XMLDoc.NewXMLDocument('1.0');
    try
      try
        cXMLDoc.LoadFromStream(aFromStream);
        cResultText := cXMLdoc.XML.Text;
      except
        on e : Exception do
        begin
          raise Exception.Create('Loading XML to Stream failed: ' + e.Message);
          exit;
        end;
      end;

      cRootNode := cXMLDoc.ChildNodes.FindNode('namhttpservice');
      cNode     := cRootNode.ChildNodes.FindNode('addrinfo');

      if cNode <> nil then
      begin
        try
          cnt := cRootNode.ChildNodes.Count;
          for i := 0 to cnt - 1 do
          begin
            resultPosition := TGeoCoderPosition.Create;
            resultAddress  := TGeoCoderAddressEx.Create;

            try
              parseXMLaddressInfo(cRootNode.ChildNodes.Get(i),resultAddress, resultPosition);
            except
              on e : Exception do
              begin
                raise EGeoCoder.Create('XML-Parser failed: ' + e.Message, cResultText);
             end;
            end;

            resultAddressInfo := TGeoCoderAddressInfo.Create(resultAddress, resultPosition);

            aToList.add(resultAddressInfo);
          end;
        except
          on e : Exception do
          begin
            raise EGeoCoder.Create('List-Creation failed: ' + e.Message, cResultText);
          end;
        end;

        result := true;
      end else
      begin
        cNode := cRootNode.ChildNodes.FindNode('error');
        raise EGeoCoder.Create('no matching address set', cResultText);
        result := false;
      end;
    finally
      cXMLDoc := nil;
    end;
  finally

  end;
end;

class procedure TGeoCoderAddressInfo.parseXMLaddressInfo(aRootNode : IXMLNode; resultAddress : TGeoCoderAddress; resultPosition : TGeoCoderPosition);
var
  cNode : IXMLNode;
  clon,
  clat  : String;
begin
  resultAddress.invalidateAddress;

  if aRootNode <> nil then
  begin
    ResultAddress.MapCid  := StrToInt(aRootNode.ParentNode.Attributes['mapcid']);
    if( resultAddress is TGeoCoderAddressEX) then
    begin
      with (resultAddress as TGeoCoderAddressEx) do
      begin
        if aRootNode.HasAttribute('administrationid') then
          fAdminID := aRootNode.Attributes['administrationid'];
        if aRootNode.HasAttribute('streetid') then
          fStreetId := aRootNode.Attributes['streetid'];
        if aRootNode.HasAttribute('roadelementid') then
          fRoadElementId := aRootNode.Attributes['roadelementid'];

        if aRootNode.HasAttribute('administrationname') then
          fAdminName := aRootNode.Attributes['administrationname'];
        if aRootNode.HasAttribute('administrationorder') then
          fAdminOrder := aRootNode.Attributes['administrationorder'];

        if aRootNode.HasAttribute('streetname') then
          fStreetName := aRootNode.Attributes['streetname'];
        if aRootNode.HasAttribute('roadelementpos') then
        begin
          fRoadElementPos := StrToFloatDef(aRootNode.Attributes['roadelementpos'], nan, MapServerFS);
        end;

      end;
    end;


    cNode := aRootNode.ChildNodes.FindNode('address');
    if cNode <> nil then
    begin
      ResultAddress.Country         := cNode.Attributes['country'];
      ResultAddress.CountryCode     := cNode.Attributes['countrycode'];
      ResultAddress.CountryPart     := cNode.Attributes['countrypart'];
      ResultAddress.CountryDistrict := cNode.Attributes['countrydistrict'];
      ResultAddress.City            := cNode.Attributes['city'];
      ResultAddress.CityPart        := cNode.Attributes['citypart'];
      ResultAddress.Street          := cNode.Attributes['street'];
      ResultAddress.House           := cNode.Attributes['house'];
      ResultAddress.ZipCode         := cNode.Attributes['zipcode'];
      ResultAddress.Building        := cNode.Attributes['building'];
      if cNode.HasAttribute('language') then ResultAddress.Language := cNode.Attributes['language'];
    end;

    cNode := aRootNode.ChildNodes.FindNode('geoposition');
    if cNode <> nil then
    begin

      clon          := cNode.Attributes['longitude'];
      clat          := cNode.Attributes['latitude'];
      resultPosition.Longitude := StrToFloat(clon, MapServerFS);
      resultPosition.Latitude  := StrToFloat(clat, MapServerFS);
    end;
  end else
  begin
    raise Exception.Create('rootNode is nil');
  end;
end;


{ **************************************************************************** }
{ ***** TGeoCoderHTTP ******************************************************** }
{ **************************************************************************** }

constructor TGeoCoderHTTP.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fHTTP := nil;
end;

destructor TGeoCoderHTTP.Destroy;
begin
  fHTTP := nil;
  inherited Destroy;
end;


{ ## Get GeoPosition By Address ############################################## }

function TGeoCoderHTTP.getGeoPositionByAddress(const aAddress: TGeoCoderAddress; aStream : TStream): TGeoCoderPosition;
var params  : THTTPConnectorParams;
    dtl     : String;
begin
  if fHTTP = nil then
  begin
    raise EHTTPError.Create('can not perform action if http connector ist not assigned!');
  end;

  params := fHTTP.createParams;
  try
    // Parameter übergeben...
    params.addInteger('mapcid', aAddress.MapCid);
    params.addString('country', aAddress.Country);
    params.addString('countrypart', aAddress.CountryPart);
    params.addString('countrydistrict', aAddress.CountryDistrict);
    params.addString('city', aAddress.City);
    params.addString('citypart', aAddress.CityPart);
    params.addString('street', aAddress.Street);
    params.addString('house', aAddress.House);
    params.addString('zipcode', aAddress.ZipCode);
    params.addString('outfmt', 'xml');

    if fHTTP.get('/getgeopositionbyaddress', params, aStream) then
    begin
      try
        result := TGeoCoderPosition.Create;
        try
          result.loadFromStream(aStream);
        except
          on e : exception do
          begin
            FreeAndNil(result);
            raise e;
          end;
        end;
      finally

      end;
    end else
    begin
      raise EHTTPError.Create('get for "/getgeopositionbyaddress" simply failed.');
    end;
  finally
    FreeAndNil(params);
  end;
end;

function TGeoCoderHTTP.getGeoPositionByAddress(const aAddress: TGeoCoderAddress): TGeoCoderPosition;
var ms  : THTTPMDSDefaultStream;
begin
  ms  := THTTPMDSDefaultStream.Create;
  try
    result := getGeoPositionByAddress(aAddress, ms);
  finally
    FreeAndNil(ms);
  end;
end;


{ ## Get Address By GeoPosition ############################################## }

function TGeoCoderHTTP.getAddressByGeoPosition(const aPosition: TGeoCoderPosition; aStream : TStream): TGeoCoderAddress;
var params  : THTTPConnectorParams;
    dtl     : String;
begin
  if fHTTP = nil then
  begin
    raise EHTTPError.Create('can not perform action if http connector ist not assigned!');
  end;

  params := fHTTP.createParams;
  try
    // Parameter übergeben...
    params.addInteger('mapcid', aPosition.MapCid);
    params.addFloat('longitude', aPosition.Longitude);
    params.addFloat('latitude', aPosition.Latitude);
    params.addString('outfmt', 'xml');

    if fHTTP.get('/getaddressbygeoposition', params, aStream) then
    begin
      try
        result := TGeoCoderAddressEx.Create;
        try
          result.loadFromStream(aStream);
        except
          on e : exception do
          begin
            FreeAndNil(result);
            raise e;
          end;
        end;
      finally

      end;
    end else
    begin
      raise EHTTPError.Create('get for "/getaddressbygeoposition" simply failed.');
    end;
  finally
    FreeAndNil(params);
  end;
end;

function TGeoCoderHTTP.getAddressByGeoPosition(const aPosition: TGeoCoderPosition): TGeoCoderAddress;
var ms  : THTTPMDSDefaultStream;
begin
  ms  := THTTPMDSDefaultStream.Create;
  try
    result := getAddressByGeoPosition(aPosition, ms);
  finally
    FreeAndNil(ms);
  end;
end;


{ ## Get AddressSet ########################################################## }

function TGeoCoderHTTP.getAddressSet (const aSearchText: String; const aMapCID : Integer; aToList: THTTPMDSList; aStream: TStream): Boolean;
var params  : THTTPConnectorParams;
    dtl     : String;
begin
  result  := false;
  if fHTTP = nil then
  begin
    raise EHTTPError.Create('can not perform action if http connector ist not assigned!');
  end;

  params := fHTTP.createParams;
  try
    // Parameter übergeben...
    params.addInteger('mapcid', aMapCID);
    params.addString('searchtext', aSearchText);
    params.addString('outfmt', 'xml');

    if fHTTP.get('/getaddressset', params, aStream) then
    begin
      try
        if not TGeoCoderAddressInfo.loadFromStreamToList(aStream, aToList) then
        begin
          raise EHTTPError.Create('could not load addressset.');
        end;
      finally

      end;
      result  := true;
    end else
    begin
      raise EHTTPError.Create('get for "/getaddressset" simply failed.');
    end;
  finally
    FreeAndNil(params);
  end;
end;

{
var

  ms                : TMemoryStream;
  cParams           : String;
  cXMLdoc           : IXMLDocument;
  cRootNode,
  cNode             : IXMLNode;
  cnt,i             : Integer;
  resultPosition    : TGeoCoderPosition;
  resultAddress     : TGeoCoderAddress;
  resultAddressInfo : TGeoCoderAddressInfo;
  cResultText       : String;

begin
  cParams := Format(fBaseParamsSearchtext, [aMapCID, aSearchText, 'xml']);
  ms := TMemoryStream.Create;

  doHTTPrequest('/getaddressset', cParams, ms);
  try
    ms.Position := 0;

    cXMLDoc := XMLDoc.NewXMLDocument('1.0');
    try
      try
        cXMLDoc.LoadFromStream(ms);
        cResultText := cXMLdoc.XML.Text;
      except
        on e : Exception do
        begin
          raise Exception.Create('Loading XML to Stream failed: ' + e.Message);
          exit;
        end;
      end;

      cRootNode := cXMLDoc.ChildNodes.FindNode('namhttpservice');
      cNode     := cRootNode.ChildNodes.FindNode('addrinfo');

      if cNode <> nil then
      begin
        try
          cnt := cRootNode.ChildNodes.Count;
          for i := 0 to cnt - 1 do
          begin
            resultPosition := TGeoCoderPosition.Create;
            resultAddress  := TGeoCoderAddressEx.Create;

            try
            parseXMLaddressInfo(cRootNode.ChildNodes.Get(i),resultAddress, resultPosition);
            except
              on e : Exception do
              begin
                raise EGeoCoder.Create('XML-Parser failed: ' + e.Message, cResultText);
             end;
            end;

            resultAddressInfo := TGeoCoderAddressInfo.Create(resultAddress, resultPosition);

            aToList.add(resultAddressInfo);
          end;
        except
          on e : Exception do
          begin
            raise EGeoCoder.Create('List-Creation failed: ' + e.Message, cResultText);
          end;
        end;

        result := true;

        if aStream <> nil then
          begin
          cXMLdoc.SaveToStream(aStream);
        end;

      end else
      begin
        cNode := cRootNode.ChildNodes.FindNode('error');
        raise EGeoCoder.Create('No matching address', cResultText);
        result := false;
      end;
    finally
      cXMLDoc := nil;
    end;
  finally
    FreeAndNil(ms);
  end;
end;
}

function TGeoCoderHTTP.getAddressSet (const aSearchText: String; const aMapCID : Integer; aToList: THTTPMDSList): Boolean;
var ms  : THTTPMDSDefaultStream;
begin
  ms  := THTTPMDSDefaultStream.Create;
  try
    result := getAddressSet(aSearchText, aMapCID, aToList, ms);
  finally
    FreeAndNil(ms);
  end;
end;


{ ## Get AddressData By Address ############################################## }

function TGeoCoderHTTP.getAddressData (const aAddress: TGeoCoderAddress; aStream : TStream) : TGeoCoderAddressEx;
var params  : THTTPConnectorParams;
    dtl     : String;
begin
  if fHTTP = nil then
  begin
    raise EHTTPError.Create('can not perform action if http connector ist not assigned!');
  end;

  params := fHTTP.createParams;
  try
    // Parameter übergeben...
    params.addInteger('mapcid', aAddress.MapCid);
    params.addString('country', aAddress.Country);
    params.addString('countrypart', aAddress.CountryPart);
    params.addString('countrydistrict', aAddress.CountryDistrict);
    params.addString('city', aAddress.City);
    params.addString('citypart', aAddress.CityPart);
    params.addString('street', aAddress.Street);
    params.addString('house', aAddress.House);
    params.addString('zipcode', aAddress.ZipCode);
    params.addString('outfmt', 'xml');

    if fHTTP.get('/getaddressdatabyaddress', params, aStream) then
    begin
      try
        result := TGeoCoderAddressEx.Create;
        try
          result.loadFromStream(aStream);
        except
          on e : exception do
          begin
            FreeAndNil(result);
            raise e;
          end;
        end;
      finally

      end;
    end else
    begin
      raise EHTTPError.Create('get for "/getaddressdatabyaddress" simply failed.');
    end;
  finally
    FreeAndNil(params);
  end;
end;
{
var
  ms                : TMemoryStream;
  cParams           : String;
  cXMLdoc           : IXMLDocument;
  cRootNode,
  cNode             : IXMLNode;
  resultAddress     : TGeoCoderAddress;
  resultPosition    : TGeoCoderPosition;
  resultAddressInfo : TGeoCoderAddressInfo;
  lat,lon           : Double;
  cResultText       : String;

begin
  cParams := Format(fBaseParamsAddress, [aAddress.MapCid, aAddress.Country,
              aAddress.CountryPart, aAddress.CountryDistrict,
              aAddress.City, aAddress.CityPart,
              aAddress.Street, aAddress.House,
              aAddress.ZipCode, 'xml']);
  ms := TMemoryStream.Create;

  doHTTPrequest('/getaddressdatabyaddress', cParams, ms);

  try
    ms.Position := 0;

    cXMLDoc := XMLDoc.NewXMLDocument('1.0');
    try
      try
        cXMLDoc.LoadFromStream(ms);
        cResultText := cXMLdoc.XML.Text;
      except
        on e : Exception do
        begin
          raise Exception.Create('Loading XML to Stream failed: ' + e.Message);
          exit;
        end;
      end;

      cRootNode := cXMLDoc.ChildNodes.FindNode('namhttpservice');
      cNode     := cRootNode.ChildNodes.FindNode('address');

      if cNode <> nil then
      begin
        resultAddress := TGeoCoderAddressEx.Create;
        resultPosition := TGeoCoderPosition.Create;

        try
          parseXMLAddress(cNode, resultPosition, resultAddress);
        except
          on e : Exception do
          begin
            raise EGeoCoder.Create('XML-Parser failed: ' + e.Message, cResultText);
          end;
        end;

        resultAddressInfo := TGeoCoderAddressInfo.Create(resultAddress, resultPosition);

        result := resultAddressInfo;

        if aStream <> nil then
        begin
          cXMLdoc.SaveToStream(aStream);
        end;

      end else
      begin
        cNode := cRootNode.ChildNodes.FindNode('error');
        raise EGeoCoder.Create('No matching address', cResultText);
      end;
    finally
      cXMLDoc := nil;
    end;
  finally
    FreeAndNil(ms);
  end;
end;
}

function TGeoCoderHTTP.getAddressData(const aAddress: TGeoCoderAddress): TGeoCoderAddressEx;
var ms  : THTTPMDSDefaultStream;
begin
  ms  := THTTPMDSDefaultStream.Create;
  try
    result := getAddressData(aAddress, ms);
  finally
    FreeAndNil(ms);
  end;
end;



{ ## Identify AddressSet ##################################################### }

function TGeoCoderHTTP.identifyAddressSet (const aAddress: TGeoCoderAddress; aToList: THTTPMDSList; aStream : TStream): Boolean;
var params  : THTTPConnectorParams;
    dtl     : String;
begin
  result  := false;
  if fHTTP = nil then
  begin
    raise EHTTPError.Create('can not perform action if http connector ist not assigned!');
  end;

  params := fHTTP.createParams;
  try
    // Parameter übergeben...
    params.addInteger('mapcid', aAddress.MapCid);
    params.addString('country', aAddress.Country);
    params.addString('countrypart', aAddress.CountryPart);
    params.addString('countrydistrict', aAddress.CountryDistrict);
    params.addString('city', aAddress.City);
    params.addString('citypart', aAddress.CityPart);
    params.addString('street', aAddress.Street);
    params.addString('house', aAddress.House);
    params.addString('zipcode', aAddress.ZipCode);
    params.addString('outfmt', 'xml');

    if fHTTP.get('/identifyaddressset', params, aStream) then
    begin
      try
        if not TGeoCoderAddressInfo.loadFromStreamToList(aStream, aToList) then
        begin
          raise EHTTPError.Create('could not load addressset.');
        end;
        result  := true;
      finally

      end;
    end else
    begin
      raise EHTTPError.Create('get for "/identifyaddressset" simply failed.');
    end;
  finally
    FreeAndNil(params);
  end;
end;

{
var
  ms                : TMemoryStream;
  cParams           : String;
  cXMLdoc           : IXMLDocument;
  cRootNode,
  cNode             : IXMLNode;
  cnt,i             : Integer;
  resultPosition    : TGeoCoderPosition;
  resultAddress     : TGeoCoderAddress;
  resultAddressInfo : TGeoCoderAddressInfo;
  cResultText       : String;

begin
  cParams := Format(fBaseParamsAddress, [aAddress.MapCid, aAddress.Country,
              aAddress.CountryPart, aAddress.CountryDistrict,
              aAddress.City, aAddress.CityPart,
              aAddress.Street, aAddress.House,
              aAddress.ZipCode, 'xml']);
  ms := TMemoryStream.Create;

  doHTTPrequest('/identifyaddressset', cParams, ms);

  try
    ms.Position := 0;

    cXMLDoc := XMLDoc.NewXMLDocument('1.0');
    try
      try
        cXMLDoc.LoadFromStream(ms);
        cResultText := cXMLdoc.XML.Text;
      except
        on e : Exception do
        begin
          raise Exception.Create('Loading XML to Stream failed: ' + e.Message);
          exit;
        end;
      end;

      cRootNode := cXMLDoc.ChildNodes.FindNode('namhttpservice');
      cNode     := cRootNode.ChildNodes.FindNode('addrinfo');

      if cNode <> nil then
      begin
        try
          cnt := cRootNode.ChildNodes.Count;
          for i := 0 to cnt - 1 do
          begin
            resultPosition := TGeoCoderPosition.Create;
            resultAddress  := TGeoCoderAddressEx.Create;

            try
            parseXMLaddressInfo(cRootNode.ChildNodes.Get(i),resultAddress, resultPosition);
            except
              on e : Exception do
              begin
                raise EGeoCoder.Create('XML-Parser failed: ' + e.Message, cResultText);
              end;
            end;

            resultAddressInfo := TGeoCoderAddressInfo.Create(resultAddress, resultPosition);

            aToList.add(resultAddressInfo);
          end;
        except
          on e : Exception do
          begin
            raise EGeoCoder.Create('List-Creation failed: ' + e.Message, cResultText);
          end;
        end;

        result := true;

        if aStream <> nil then
        begin
          cXMLdoc.SaveToStream(aStream);
        end;

      end else
      begin
        cNode := cRootNode.ChildNodes.FindNode('error');
        raise EGeoCoder.Create('No matching address', cResultText);
        result := false;
      end;
    finally
      cXMLDoc := nil;
    end;
  finally
    FreeAndNil(ms);
  end;
end;
}

function TGeoCoderHTTP.identifyAddressSet(const aAddress: TGeoCoderAddress; aToList: THTTPMDSList): Boolean;
var ms  : THTTPMDSDefaultStream;
begin
  ms  := THTTPMDSDefaultStream.Create;
  try
    result := identifyAddressSet(aAddress, aToList, ms);
  finally
    FreeAndNil(ms);
  end;
end;





initialization
  initXMLSchemaDataTypesV2FormatSettings(MapServerFS);

finalization

end.
