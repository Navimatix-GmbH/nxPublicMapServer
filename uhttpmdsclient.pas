unit uhttpmdsclient;

interface

uses types, classes, SysUtils, IdHTTP, XMLIntf, XMLDoc, uhttpmdsbase;

type
  

  // Data Structures
  THTTPMDSClientRestCommandInfo = class
  private
    fCommandIndex       : Integer;
    fCommandAuth        : Boolean;
    fCommand            : String;
  public
    constructor Create(aCommandIndex : Integer; aCommandAuth : Boolean; aCommand : String);
    destructor Destroy; override;

    property CommandIndex : Integer read fCommandIndex;
    property CommandAuth : Boolean read fCommandAuth;
    property Command      : String  read fCommand;
  end;

  THTTPMDSClientVersion = class
  private
    fApplicationName    : String;
    fServiceName        : String;
    fVersion            : String;
    fApplicationVersion : String;
    fServiceOperator    : String;
    fLicence            : String;
  protected
    procedure parseXMLVersion(aRootNode : IXMLNode); virtual;
  public
    constructor Create;
    destructor Destroy; override;

    procedure loadFromStream(aFromStream : TStream); virtual;

    property ApplicationName    : String read fApplicationName;
    property ServiceName        : String read fServiceName;
    property Version            : String read fVersion;
    property ApplicationVersion : String read fApplicationVersion;
    property ServiceOperator    : String read fServiceOperator;
    property Licence            : String read fLicence;
  end;

  THTTPMDSClientState = class
  private
    fHealthy            : Boolean;
    fHealthIndex        : Integer;
    fMemUsed            : Int64;
    fMemLoad            : Int64;
    fCPU                : String;
    fCPUCount           : Integer;
    fCPUSpeeds          : String;
    fDBMaxTransactionId : Int64;
    fDBSize             : Int64;
    fDBFreeStorage      : Int64;
    fDBTotalStorage     : Int64;
  protected
    procedure parseXMLState(aRootNode : IXMLNode); virtual;
  public
    constructor Create;
    destructor Destroy; override;

    procedure loadFromStream(aFromStream : TStream); virtual;

    property Healthy            : Boolean read fHealthy;
    property HealthIndex        : Integer read fHealthIndex;
    property MemUsed            : Int64 read fMemUsed;
    property MemLoad            : Int64 read fMemLoad;
    property CPU                : String read fCPU;
    property CPUCount           : Integer read fCPUCount;
    property CPUSpeeds          : String read fCPUSpeeds;
    property DBMaxTransactionId : Int64 read fDBMaxTransactionId;
    property DBSize             : Int64 read fDBSize;
    property DBFreeStorage      : Int64 read fDBFreeStorage;
    property DBTotalStorage     : Int64 read fDBTotalStorage;
  end;

  THTTPMDSClientCapabilities = class
  private
    fSupportsRendering        : Boolean;
    fSupportsGeoCoding        : Boolean;
    fSupportsReverseGeoCoding : Boolean;
    fSupportsRouteCalculation : Boolean;
    fRestCommandList          : THTTPMDSList;
  protected
    procedure parseXMLCapabilities(aRootNode : IXMLNode); virtual;
  public
    constructor Create;
    destructor Destroy; override;

    procedure loadFromStream(aFromStream : TStream); virtual;

    procedure add(aCommandIndex : Integer; aCommandAuth : Boolean; aCommand : String);
    procedure clear;

    property SupportsRendering : Boolean read fSupportsRendering;
    property SupportsGeoCoding : Boolean read fSupportsGeoCoding;
    property SupportsRouteCalculation : Boolean read fSupportsRouteCalculation;
    property SupportsReverseGeoCoding : Boolean read fSupportsReverseGeoCoding;
    property RestCommandList          : THTTPMDSList   read fRestCommandList; // TODO ist das richtig ?
  end;

  THTTPMDSClientMapInfo = class
  private
    fMapcid               : Integer;
    fMapIdent             : String;
    fMapName              : String;
    fMapVendorName        : String;
    fMapRawDataVendorName : String;
    fMapFilename          : String;
    fMapFormatID          : Integer;
    fMapFormatVersion     : Integer;
    fMapMarket            : String;
    fScaleMin             : Double;
    fScaleMax             : Double;
    fScaleStart           : Double;
    fEntityStreamCount    : Integer;
    fCreatedTS            : TDateTime;
    fMapUpdateHint        : Boolean;
    fMapExpiration        : Boolean;
    fMapDateUpdateHint    : TDateTime;
    fMapDateExpiration    : TDateTime;
    fMinX                 : Double;
    fMinY                 : Double;
    fMaxX                 : Double;
    fMaxY                 : Double;
  protected
    procedure parseXMLMapsInfo(aRootNode : IXMLNode); virtual;
  public
    Constructor Create;
    destructor Destroy; override;

    class function format(const aMapInfo : THTTPMDSClientMapInfo) : String;
    class function loadFromStreamToList(const aFromStream : TStream; aToList : THTTPMDSList) : Boolean;

    property MapcID               : Integer read fmapcid write fmapcid;
    property MapIdent             : String read fmapident write fmapident;
    property MapName              : String read fMapName write fMapName;
    property MapVendorName        : String read fMapVendorName write fMapVendorName;
    property MapRawDataVendorName : String read fMapRawDataVendorName write fMapRawDataVendorName;
    property MapFilename          : String read fMapFilename write fMapFilename;
    property MapFormatID          : Integer read fMapFormatID write fMapFormatID;
    property MapFormatVersion     : Integer read fMapFormatVersion write fMapFormatVersion;
    property MapMarket            : String read fMapMarket write fMapMarket;
    property ScaleMin             : Double read fScaleMin write fScaleMin;
    property ScaleMax             : Double read fScaleMax write fScaleMax;
    property ScaleStart           : Double read fScaleStart write fScaleStart;
    property EntityStreamCount    : Integer read fEntityStreamCount write fEntityStreamCount;
    property CreatedTS            : TDateTime read fCreatedTS write fCreatedTS;
    property MapUpdateHint        : Boolean read fMapUpdateHint write fMapUpdateHint;
    property MapExpiration        : Boolean read fMapExpiration write fMapExpiration;
    property MapDateUpdateHint    : TDateTime read fMapDateUpdateHint write fMapDateUpdateHint;
    property MapDateExpiration    : TDateTime read fMapDateExpiration write fMapDateExpiration;
    property MinX                : Double read fMinX write fMinX;
    property MinY                : Double read fMinY write fMinY;
    property MaxX                : Double read fMaxX write fMaxX;
    property MaxY                : Double read fMaxY write fMaxY;

  end;

  THTTPMDSClientStretchStrategy = (HTTPMDSMISS_STRETCH, HTTPMDSMISS_CENTER, HTTPMDSMISS_FIT);

  // HTTP-Servie-Client
  THTTPMDSClient = class (TComponent)
  private
    fHTTP                 : THTTPConnector;
  protected

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function getVersion(aStream : TStream)       : THTTPMDSClientVersion; overload;
    function getVersion                          : THTTPMDSClientVersion; overload;

    function getState(aStream : TStream)         : THTTPMDSClientState; overload;
    function getState                            : THTTPMDSClientState; overload;

    function getCapabilities(aStream : TStream)  : THTTPMDSClientCapabilities; overload;
    function getCapabilities                     : THTTPMDSClientCapabilities; overload;

    function getMapsInfo(aMapsInfoList : THTTPMDSList; aStream : TStream)  : Boolean; overload;
    function getMapsInfo(aMapsInfoList : THTTPMDSList)  : boolean; overload;

    function getMapIcon(aRotId, aRostId : Integer; aWidth, aHeight : Integer; aStream : TStream; aStrategy : THTTPMDSClientStretchStrategy = HTTPMDSMISS_STRETCH; aEmbeddedInfo : Boolean = false) : TStream; overload;
    function getMapIcon(aRotId, aRostId : Integer; aWidth, aHeight : Integer; aStrategy : THTTPMDSClientStretchStrategy = HTTPMDSMISS_STRETCH; aEmbeddedInfo : Boolean = false) : TStream; overload;

  published
    property HTTP : THTTPConnector read fHTTP write fHTTP;
  end;



implementation

uses Math;

{ **************************************************************************** }
{ ***** FormatSettings ******************************************************* }
{ **************************************************************************** }

var MapServerFS : TFormatSettings;

function _StrToFloat(const S: string;
  const FormatSettings: TFormatSettings): Extended;
begin
  if (LowerCase(s) = 'nan') or (LowerCase(s) = '-nan') then
  begin
    result := nan;
  end else
  begin
    result := StrToFloat(S, FormatSettings);
  end;
end;

function _DateTimeToStr(const DateTime: TDateTime;
  const FormatSettings: TFormatSettings): string;
begin
  if IsNan(DateTime) then
  begin
    result := 'NaN';
  end else
  begin
    result := DateToStr(DateTime, FormatSettings);
  end;

end;

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
    CurrencyString:='�';
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
    LongMonthNames[3]:='M�rz';
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
{ ***** THTTPMDSClientRestCommandInfo **************************************** }
{ **************************************************************************** }

constructor THTTPMDSClientRestCommandInfo.Create(aCommandIndex : Integer; aCommandAuth : Boolean; aCommand : String);
begin
  inherited Create;
  fCommandIndex := aCommandIndex;
  fCommandAuth  := aCommandAuth;
  fCommand      := aCommand;
end;

destructor THTTPMDSClientRestCommandInfo.Destroy;
begin
  inherited Destroy;
end;


{ **************************************************************************** }
{ ***** THTTPMDSClientVersion ************************************************ }
{ **************************************************************************** }

constructor THTTPMDSClientVersion.Create;
begin
  inherited Create;
  fApplicationName    := '';
  fServiceName        := '';
  fVersion            := '';
  fApplicationVersion := '';
end;

destructor THTTPMDSClientVersion.Destroy;
begin
  inherited Destroy;
end;

procedure THTTPMDSClientVersion.loadFromStream(aFromStream : TStream);
var cXMLdoc   : IXMLDocument;
    cRootNode : IXMLNode;
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
    cRootNode := cXMLDoc.ChildNodes.FindNode('VersionInfo');
    if cRootNode <> nil then
    begin
      try
        parseXMLVersion(cRootNode);
      except
        on e : Exception do
        begin
          raise Exception.Create('XML-Parser failed: ' + e.Message);
        end;
      end;
    end else
    begin
      cRootNode := cRootNode.ChildNodes.FindNode('error');
      raise Exception.Create('no version available');
    end;
  finally
    cXMLDoc := nil;
  end;
end;

procedure THTTPMDSClientVersion.parseXMLVersion(aRootNode : IXMLNode);
var
  cNode : IXMLNode;
  cApplicationName,
  cServiceName,
  cVersion,
  cApplicationVersion : String;
begin
  if aRootNode <> nil then
  begin
    cNode := aRootNode.ChildNodes.FindNode('applicationName');
    if cNode <> nil then fApplicationName := cNode.Text;

    cNode := aRootNode.ChildNodes.FindNode('serviceName');
    if cNode <> nil then fServiceName := cNode.Text;

    cNode := aRootNode.ChildNodes.FindNode('version');
    if cNode <> nil then fVersion := cNode.Text;

    cNode := aRootNode.ChildNodes.FindNode('applicationVersion');
    if cNode <> nil then fApplicationVersion := cNode.Text;

    cNode := aRootNode.ChildNodes.FindNode('serviceOperator');
    if cNode <> nil then fServiceOperator := cNode.Text;

    cNode := aRootNode.ChildNodes.FindNode('licence');
    if cNode <> nil then fLicence := cNode.Text;

  end else
  begin
    raise Exception.Create('rootNode is nil');
  end;
end;


{ **************************************************************************** }
{ ***** THTTPMDSClientState ************************************************** }
{ **************************************************************************** }

constructor THTTPMDSClientState.Create;
begin
  inherited Create;
  fHealthy            := false;
  fHealthIndex        := 0;
  fMemUsed            := 0;
  fMemLoad            := 0;
  fCPU                := '';
  fCPUCount           := 0;
  fCPUSpeeds          := '';
end;

destructor THTTPMDSClientState.Destroy;
begin
  inherited Destroy;
end;

procedure THTTPMDSClientState.loadFromStream(aFromStream : TStream);
var cXMLdoc   : IXMLDocument;
    cRootNode : IXMLNode;
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
    cRootNode := cXMLDoc.ChildNodes.FindNode('StateInfo');
    if cRootNode <> nil then
    begin
      try
        parseXMLState(cRootNode);
      except
        on e : Exception do
        begin
          raise Exception.Create('XML-Parser failed: ' + e.Message);
        end;
      end;
    end else
    begin
      cRootNode := cRootNode.ChildNodes.FindNode('error');
      raise Exception.Create('no state available');
    end;
  finally
    cXMLDoc := nil;
  end;
end;

procedure THTTPMDSClientState.parseXMLState(aRootNode : IXMLNode);
var
  cNode : IXMLNode;
  chealthy : boolean; chealthindex : Integer; cmemused, cmemload: Int64;
  ccpu, ccpuspeeds : String; ccpucount : Integer;
begin
  if aRootNode <> nil then
  begin
    cNode := aRootNode.ChildNodes.FindNode('healthy');
    if cNode <> nil then
    begin
      chealthy := StrToBoolDef(cNode.Text, false);
      fHealthy := chealthy;
    end;

    cNode := aRootNode.ChildNodes.FindNode('healthindex');
    if cNode <> nil then
    begin
      chealthindex := StrToIntDef(cNode.Text, -1);
      fHealthIndex := chealthindex;
    end;
    // DB-State...
    cNode := aRootNode.ChildNodes.FindNode('dbmaxtransactionid');
    if cNode <> nil then
    begin
      fDBMaxTransactionId := StrToInt64Def(cNode.Text, -1);
    end;
    cNode := aRootNode.ChildNodes.FindNode('dballsize');
    if cNode <> nil then
    begin
      fDBSize := StrToInt64Def(cNode.Text, -1);
    end;
    cNode := aRootNode.ChildNodes.FindNode('dbfreestoragesize');
    if cNode <> nil then
    begin
      fDBFreeStorage := StrToInt64Def(cNode.Text, -1);
    end;
    cNode := aRootNode.ChildNodes.FindNode('dbtotalstoragesize');
    if cNode <> nil then
    begin
      fDBTotalStorage := StrToInt64Def(cNode.Text, -1);
    end;
    cNode := aRootNode.ChildNodes.FindNode('memused');
    if cNode <> nil then
    begin
      cmemused := StrToInt64Def(cNode.Text, 0);
      fMemUsed := cmemused;
    end;

    cNode := aRootNode.ChildNodes.FindNode('memload');
    if cNode <> nil then
    begin
      cmemload := StrToInt64Def(cNode.Text, 0);
      fMemLoad := cmemload;
    end;

    cNode := aRootNode.ChildNodes.FindNode('cpu');
    if cNode <> nil then
    begin
      ccpu := cNode.Text;
      fCPU := ccpu;
    end;

    cNode := aRootNode.ChildNodes.FindNode('cpucount');
    if cNode <> nil then
    begin
      ccpucount := StrToIntDef(cNode.Text, 0);
      fCPUCount  := ccpucount;
    end;

    cNode := aRootNode.ChildNodes.FindNode('cpuspeed');
    if cNode <> nil then
    begin
      ccpuspeeds := cNode.Text;
      fCPUSpeeds := ccpuspeeds;
    end;

  end else
  begin
    raise Exception.Create('rootNode is nil');
  end;
end;

{ **************************************************************************** }
{ ***** THTTPMDSClientCapabilities ******************************************* }
{ **************************************************************************** }

constructor THTTPMDSClientCapabilities.Create;
begin
  inherited Create;
  fSupportsRendering        := false;
  fSupportsGeoCoding        := false;
  fSupportsReverseGeoCoding := false;
  fSupportsRouteCalculation := false;
  fRestCommandList          := THTTPMDSList.Create;
end;

destructor THTTPMDSClientCapabilities.Destroy;
var
  i: Integer;
  o: TObject;
begin
  for i := 0 to fRestCommandList.Count - 1 do
  begin
    o := TObject(fRestCommandList[i]);
    FreeAndNil(o);
  end;
  FreeAndNil(fRestCommandList);
  inherited Destroy;
end;

procedure THTTPMDSClientCapabilities.loadFromStream(aFromStream : TStream);
var cXMLdoc   : IXMLDocument;
    cRootNode : IXMLNode;
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
    cRootNode := cXMLDoc.ChildNodes.FindNode('Capabilities');
    if cRootNode <> nil then
    begin
      try
        parseXMLCapabilities(cRootNode);
      except
        on e : Exception do
        begin
          raise Exception.Create('XML-Parser failed: ' + e.Message);
        end;
      end;
    end else
    begin
      cRootNode := cRootNode.ChildNodes.FindNode('error');
      raise Exception.Create('no capabilities available');
    end;
  finally
    cXMLDoc := nil;
  end;
end;

procedure THTTPMDSClientCapabilities.parseXMLCapabilities(aRootNode : IXMLNode);
var
  cNode                     : IXMLNode;
  cNodeList                 : IXMLNodeList;
  cRestCommand              : String;
  cRestCommandIndex, i      : Integer;
  cRestCommandAuth          : Boolean;
begin
  self.clear;

  if aRootNode <> nil then
  begin
    cNode := aRootNode.ChildNodes.FindNode('SupportsRendering');
    if cNode <> nil then fSupportsRendering := StrToBool(cNode.Text);

    cNode := aRootNode.ChildNodes.FindNode('SupportsGeoCoding');
    if cNode <> nil then fSupportsGeoCoding := StrToBool(cNode.Text);

    cNode := aRootNode.ChildNodes.FindNode('SupportsReverseGeoCoding');
    if cNode <> nil then fSupportsReverseGeoCoding := StrToBool(cNode.Text);

    cNode := aRootNode.ChildNodes.FindNode('SupportsRouteCalculation');
    if cNode <> nil then fSupportsRouteCalculation := StrToBool(cNode.Text);

    try
      cNode := aRootNode.ChildNodes.FindNode('RESTCommands');
      if cNode <> nil then
      begin
        cNodeList := cNode.GetChildNodes();
        for i := 0 to cNodeList.Count - 1 do
        begin
          cNode := cNodeList.Get(i);
          cRestCommandIndex := StrToIntDef(cNode.Attributes['index'], -1);
          cRestCommandAuth := StrToBool(cNode.Attributes['auth']);
          if cRestCommandIndex >= 0 then
          begin
            cRestCommand      := cNode.Text;
            self.add(cRestCommandIndex, cRestCommandAuth, cRestCommand);
          end;

        end;
      end;
    except
      on E: Exception do
      begin
        raise;
      end;
    end;
  end else
  begin
    raise Exception.Create('rootNode is nil');
  end;
end;

procedure THTTPMDSClientCapabilities.add(aCommandIndex : Integer; aCommandAuth : Boolean; aCommand : String);
var
  cRestCommandInfo : THTTPMDSClientRestCommandInfo;
begin
  cRestCommandInfo := THTTPMDSClientRestCommandInfo.Create(aCommandIndex, aCommandAuth, aCommand);
  fRestCommandList.Add(cRestCommandInfo);
end;

procedure THTTPMDSClientCapabilities.clear;
begin
  clearList(fRestCommandList);
end;


{ **************************************************************************** }
{ ***** THTTPMDSClientMapsInfo *********************************************** }
{ **************************************************************************** }

constructor THTTPMDSClientMapInfo.Create;
begin
  inherited Create;
  fmapcid               := -1;
  fmapident             := '';
  fMapName              := '';
  fMapVendorName        := '';
  fMapRawDataVendorName := '';
  fMapFilename          := '';
  fMapFormatID          := 0;
  fMapFormatVersion     := 0;
  fScaleMin             := 0;
  fScaleMax             := 0;
  fScaleStart           := 0;
  fEntityStreamCount    := 0;
  fCreatedTS            := 0;
  fMapUpdateHint        := false;
  fMapExpiration        := false;
  fMapDateUpdateHint    := 0;
  fMapDateExpiration    := 0;
  fMinX                 := nan;
  fMinY                 := nan;
  fMaxX                 := nan;
  fMaxY                 := nan;
end;

destructor THTTPMDSClientMapInfo.Destroy;
begin
  inherited Destroy;
end;

class function THTTPMDSClientMapInfo.format(const aMapInfo : THTTPMDSClientMapInfo) : String;
var cStr : String;
const LF = #13#10;
begin
  with aMapInfo do
  begin
    cStr := IntToStr(MapcID) + ' ' + MapName + LF +
            MapIdent + LF + LF +

            'MapFilename: ' + MapFilename + LF +
            'MapVendorName: ' + MapVendorName + LF +
            'MapRawDataBendorName: ' + MapRawDataVendorName + LF +
            'Created: ' + DateTimeToStr(CreatedTS, MapServerFS) + LF + LF +

            'MapFormatID: ' + IntToStr(MapFormatID) + LF +
            'MapFormatVersion: ' + IntToStr(MapFormatID) + LF +
            'EntityStreamCount: ' + IntToStr(EntityStreamCount) + LF + LF +

            'MinX: ' + FloatToStr(MinX) + LF +
            'MinY: ' + FloatToStr(MinY) + LF +
            'MaxX: ' + FloatToStr(MaxX) + LF +
            'MaxY: ' + FloatToStr(MaxY) + LF + LF +

            'ScaleMin: ' + FloatToStr(ScaleMin, MapServerFS) + LF +
            'ScaleMax: ' + FloatToStr(ScaleMax, MapServerFS) + LF +
            'ScaleStart: ' + FloatToStr(ScaleStart, MapServerFS)+ LF + LF;
     if MapUpdateHint then
     begin
       cStr := cStr + 'MapUpdateHint: ' + BoolToStr(MapUpdateHint, true) + ' on: ' + _DateTimeToStr(MapDateUpdateHint, MapServerFS) + LF;
     end else
     begin
       cStr := cStr + 'MapUpdateHint: ' + BoolToStr(MapUpdateHint, true) + LF;
     end;
     if MapExpiration then
     begin
       cStr := cStr + 'MapExpiration: ' + BoolToStr(MapUpdateHint, true) + ' on: ' + _DateTimeToStr(MapDateExpiration, MapServerFS);
     end else
     begin
       cStr := cStr + 'MapExpiration: ' + BoolToStr(MapUpdateHint, true);
     end;
    result := cStr;
  end;
end;

class function THTTPMDSClientMapInfo.loadFromStreamToList(const aFromStream : TStream; aToList : THTTPMDSList) : Boolean;
var cXMLdoc   : IXMLDocument;
    cRootNode : IXMLNode;
    i         : Integer;
    cmapinfoitem  : THTTPMDSClientMapInfo;
begin
  result  := false;
  if (aFromStream = nil) or (aToList = nil) then
  begin
    exit;
  end;

  cXMLDoc := XMLDoc.NewXMLDocument('1.0');
  try
    try
      cXMLDoc.LoadFromStream(aFromStream);
    except
      on e : Exception do
      begin
        raise Exception.Create('Loading XML to Stream failed: ' + e.Message);
        exit;
      end;
    end;

    cRootNode := cXMLDoc.ChildNodes.FindNode('MapsInfo');

    if cRootNode <> nil then
    begin
      try
        for i := 0 to cRootNode.ChildNodes.Count - 1 do
        begin
          try
            cmapinfoitem := THTTPMDSClientMapInfo.Create;
            cmapinfoitem.parseXMLMapsInfo(cRootNode.ChildNodes.Get(i));
            aToList.add(cmapinfoitem);
          except
            on e : Exception do
            begin
              raise Exception.Create('XML-Parser failed: ' + e.Message);
            end;
          end;

        end;
        result := true;
      except
      on e : Exception do
        begin
         raise Exception.Create('List-Creation failed: ' + e.Message);
         result := false;
        end;
      end;
    end else
    begin
      cRootNode := cRootNode.ChildNodes.FindNode('error');
      raise Exception.Create('no mapsinfo avaliable');
      result := false;
    end;
  finally
    cXMLDoc := nil;
  end;
end;

procedure THTTPMDSClientMapInfo.parseXMLMapsInfo(aRootNode : IXMLNode);
var
  cNode                     : IXMLNode;
begin
  if aRootNode <> nil then
  begin
    try
      with self do
      begin
        MapcID   := StrToInt(aRootNode.Attributes['index']);
        MapIdent := aRootNode.Attributes['mapident'];

        cNode := aRootNode.ChildNodes.FindNode('Detail');
        MapName                  := cNode.Attributes['MapName'];
        MapVendorName            := cNode.Attributes['MapVendorName'];
        MapRawDataVendorName     := cNode.Attributes['MapRawDataVendorName'];
        MapFilename              := cNode.Attributes['MapFilename'];
        MapFormatID              := StrToInt(cNode.Attributes['MapFormatId']);
        MapFormatVersion         := StrToInt(cNode.Attributes['MapFormatVersion']);
        MapMarket                := cNode.Attributes['MapMarket'];
        ScaleMin                 := _StrToFloat(cNode.Attributes['ScaleMin'], MapServerFS);
        ScaleMax                 := _StrToFloat(cNode.Attributes['ScaleMax'], MapServerFS);
        ScaleStart               := _StrToFloat(cNode.Attributes['ScaleStart'], MapServerFS);
        EntityStreamCount        := StrToInt(cNode.Attributes['EntityStreamCount']);
        CreatedTS                := StrToDateTimeDef(cNode.Attributes['CreatedTS'],nan, MapServerFS);
        MapUpdateHint            := StrToBool(cNode.Attributes['MapUpdateHint']);
        MapExpiration            := StrToBool(cNode.Attributes['MapExpiration']);
        MapDateUpdateHint        := StrToDateTimeDef(cNode.Attributes['MapDateUpdateHint'], nan, MapServerFS);
        MapDateExpiration        := StrToDateTimeDef(cNode.Attributes['MapDateExpiration'], nan, MapServerFS);
        cNode := cNode.ChildNodes.FindNode('MapBounds');
        MinX                     := _StrToFloat(cNode.Attributes['minx'], MapServerFS);
        MinY                     := _StrToFloat(cNode.Attributes['miny'], MapServerFS);
        MaxX                     := _StrToFloat(cNode.Attributes['maxx'], MapServerFS);
        MaxY                     := _StrToFloat(cNode.Attributes['maxy'], MapServerFS);
      end;
    except
      on e : Exception do
      begin
        raise;
      end;
    end;
  end else
  begin
    raise Exception.Create('rootNode is nil');
  end;
end;


{ **************************************************************************** }
{ ***** THTTPMDSClient ******************************************************* }
{ **************************************************************************** }

constructor THTTPMDSClient.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fHTTP := nil;
end;

destructor THTTPMDSClient.Destroy;
begin
  fHTTP := nil;
  inherited Destroy;
end;



{ ## Get Version ############################################################# }

function THTTPMDSClient.getVersion(aStream: TStream) : THTTPMDSClientVersion;
var params  : THTTPConnectorParams;
    dtl     : String;
begin
  if fHTTP = nil then
  begin
    raise EHTTPError.Create('can not perform action if http connector ist not assigned!');
  end;

  params := fHTTP.createParams;
  try
    // keine Parameter...
    if fHTTP.get('/version', params, aStream) then
    begin
      try
        result := THTTPMDSClientVersion.Create;
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
      raise EHTTPError.Create('get for "/version" simply failed.');
    end;
  finally
    FreeAndNil(params);
  end;
end;

function THTTPMDSClient.getVersion: THTTPMDSClientVersion;
var ms : THTTPMDSDefaultStream;
begin
  ms  := THTTPMDSDefaultStream.Create;
  try
    result := getVersion(ms);
  finally
    FreeAndNil(ms);
  end;
end;


{ ## Get State ############################################################# }

function THTTPMDSClient.getState(aStream: TStream) : THTTPMDSClientState;
var params : THTTPConnectorParams;
    dtl : String;
begin
  if fHTTP = nil then
  begin
    raise EHTTPError.Create('can not perform action if http connector ist not assigned!');
  end;

  params := fHTTP.createParams;
  try
    // keine Parameter...
    if fHTTP.get('/state', params, aStream) then
    begin
      try
        result := THTTPMDSClientState.Create;
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
      raise EHTTPError.Create('get for "/state" simply failed.');
    end;
  finally
    FreeAndNil(params);
  end;
end;

function THTTPMDSClient.getState: THTTPMDSClientState;
var ms : THTTPMDSDefaultStream;
begin
  ms  := THTTPMDSDefaultStream.Create;
  try
    result := getState(ms);
  finally
    FreeAndNil(ms);
  end;
end;

{ ## Get Capabilities ######################################################## }

function THTTPMDSClient.getCapabilities(aStream : TStream): THTTPMDSClientCapabilities;
var params : THTTPConnectorParams;
    dtl : String;
begin
  if fHTTP = nil then
  begin
    raise EHTTPError.Create('can not perform action if http connector ist not assigned!');
  end;

  params := fHTTP.createParams;
  try
    // keine Parameter...
    if fHTTP.get('/capabilities', params, aStream) then
    begin
      try
        result := THTTPMDSClientCapabilities.Create;
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
      raise EHTTPError.Create('get for "/capabilities" simply failed.');
    end;
  finally
    FreeAndNil(params);
  end;
end;

{var
  cIdHTTP   : TIdHTTP;
  ms        : TMemoryStream;
  cURL      : String;
  cXMLdoc   : IXMLDocument;
  cRootNode : IXMLNode;
  aCapabilities  : THTTPMDSClientCapabilities;

begin
  cIdHTTP := TIdHTTP.Create;
  cIdHTTP.ProtocolVersion := pv1_1;
  cIdHTTP.ReadTimeout := 30000;
  ms := TMemoryStream.Create;

  if (fUsername <> '') and (fPassword <> '') then
  begin
    cIdHTTP.Request.Username := fUsername;
    cIDHTTP.Request.Password := fPassword;
    cIdHTTP.Request.BasicAuthentication := true;
  end;


  try
    try

      cURL := fBaseURL + '/capabilities';
      cURL := cIdHTTP.URL.URLEncode(cURL);
      try
        cIdHTTP.Get(cURL, ms);
      except
        FreeAndNil(cIdHTTP);
        cIdHTTP := TIdHTTP.Create;
        cIdHTTP.ProtocolVersion := pv1_1;
        cIdHTTP.ReadTimeout := 30000;
        try
          cIdHTTP.Get(cURL, ms);
        except
          on e : exception do
          begin
            raise EHTTPCode.Create('HTTP-Request failed: ' + e.Message, cIdHTTP.ResponseCode);
            exit;
          end;
        end;
      end;
    finally
      FreeAndNil(cIdHTTP);
    end;

    ms.Position := 0;

    cXMLDoc := XMLDoc.NewXMLDocument('1.0');
    try
      try
        cXMLDoc.LoadFromStream(ms);
      except
        on e : Exception do
        begin
          raise Exception.Create('Loading XML to Stream failed: ' + e.Message);
          exit;
        end;
      end;

    cRootNode := cXMLDoc.ChildNodes.FindNode('Capabilities');

    if cRootNode <> nil then
      begin

        try
          aCapabilities := parseXMLCapabilities(cRootNode);
        except
          on e : Exception do
          begin
            raise Exception.Create('XML-Parser failed: ' + e.Message);
          end;
        end;

        result := aCapabilities;

        if aStream <> nil then
          begin
          cXMLdoc.SaveToStream(aStream);
        end;

      end else
      begin
        cRootNode := cRootNode.ChildNodes.FindNode('error');
        raise Exception.Create('No matching address');
      end;
    finally
      cXMLDoc := nil;
    end;
  finally
    FreeAndNil(ms);
  end;
end;
}

function THTTPMDSClient.getCapabilities(): THTTPMDSClientCapabilities;
var ms : THTTPMDSDefaultStream;
begin
  ms  := THTTPMDSDefaultStream.Create;
  try
    result := getCapabilities(ms);
  finally
    FreeAndNil(ms);
  end;
end;


{ ## Get MapsInfo ############################################################ }

function THTTPMDSClient.getMapsInfo(aMapsInfoList: THTTPMDSList; aStream : TStream): boolean;
var params : THTTPConnectorParams;
    dtl : String;
begin
  if fHTTP = nil then
  begin
    raise EHTTPError.Create('can not perform action if http connector ist not assigned!');
  end;

  params := fHTTP.createParams;
  try
    // keine Parameter...
    if fHTTP.get('/mapsinfo', params, aStream) then
    begin
      try
        try
          result := THTTPMDSClientMapInfo.loadFromStreamToList(aStream, aMapsInfoList);
        except
          on e : exception do
          begin
            result  := false;
            raise e;
          end;
        end;
      finally

      end;
    end else
    begin
      raise EHTTPError.Create('get for "/mapsinfo" simply failed.');
    end;
  finally
    FreeAndNil(params);
  end;
end;

{
var
  cIdHTTP   : TIdHTTP;
  ms        : TMemoryStream;
  cURL      : String;
  cXMLdoc   : IXMLDocument;
  cRootNode : IXMLNode;
  i         : Integer;

begin
  cIdHTTP := TIdHTTP.Create;
  cIdHTTP.ProtocolVersion := pv1_1;
  cIdHTTP.ReadTimeout := 30000;
  ms := TMemoryStream.Create;

  if (fUsername <> '') and (fPassword <> '') then
  begin
    cIdHTTP.Request.Username := fUsername;
    cIDHTTP.Request.Password := fPassword;
    cIdHTTP.Request.BasicAuthentication := true;
  end;


  try
    try

      cURL := fBaseURL + '/mapsinfo';
      cURL := cIdHTTP.URL.URLEncode(cURL);
      try
        cIdHTTP.Get(cURL, ms);
      except
        FreeAndNil(cIdHTTP);
        cIdHTTP := TIdHTTP.Create;
        cIdHTTP.ProtocolVersion := pv1_1;
        cIdHTTP.ReadTimeout := 30000;
        try
          cIdHTTP.Get(cURL, ms);
        except
          on e : exception do
          begin
            raise EHTTPCode.Create('HTTP-Request failed: ' + e.Message, cIdHTTP.ResponseCode);
            exit;
          end;
        end;
      end;
    finally
      FreeAndNil(cIdHTTP);
    end;

    ms.Position := 0;

    cXMLDoc := XMLDoc.NewXMLDocument('1.0');
    try
      try
        cXMLDoc.LoadFromStream(ms);
      except
        on e : Exception do
        begin
          raise Exception.Create('Loading XML to Stream failed: ' + e.Message);
          exit;
        end;
      end;

    cRootNode := cXMLDoc.ChildNodes.FindNode('MapsInfo');

    if cRootNode <> nil then
      begin
        try
          for i := 0 to cRootNode.ChildNodes.Count - 1 do
          begin

            try
            aMapsInfoList.add(parseXMLMapsInfo(cRootNode.ChildNodes.Get(i)));
            except
              on e : Exception do
              begin
                raise Exception.Create('XML-Parser failed: ' + e.Message);
              end;
            end;

          end;
          result := true;
        except
        on e : Exception do
          begin
           raise Exception.Create('List-Creation failed: ' + e.Message);
           result := false;
          end;
        end;

        if aStream <> nil then
          begin
          cXMLdoc.SaveToStream(aStream);
        end;

      end else
      begin
        cRootNode := cRootNode.ChildNodes.FindNode('error');
        raise Exception.Create('No matching address');
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

function THTTPMDSClient.getMapsInfo(aMapsInfoList : THTTPMDSList): boolean;
var ms : THTTPMDSDefaultStream;
begin
  ms  := THTTPMDSDefaultStream.Create;
  try
    result := getMapsInfo(aMapsInfoList, ms);
  finally
    FreeAndNil(ms);
  end;
end;

function THTTPMDSClient.getMapIcon(aRotId, aRostId : Integer; aWidth, aHeight : Integer; aStream : TStream; aStrategy : THTTPMDSClientStretchStrategy = HTTPMDSMISS_STRETCH; aEmbeddedInfo : Boolean = false) : TStream;
var params : THTTPConnectorParams;
    dtl, cStrategy : String;
begin
  if fHTTP = nil then
  begin
    raise EHTTPError.Create('can not perform action if http connector ist not assigned!');
  end;

  case aStrategy of
    HTTPMDSMISS_STRETCH: cStrategy := 'stretch';
    HTTPMDSMISS_CENTER: cStrategy := 'center';
    HTTPMDSMISS_FIT: cStrategy := 'fit';
  else
    cStrategy := '';
  end;

  params := fHTTP.createParams;
  try
    // Parameter...
    params.addInteger('rot', aRotId);
    params.addInteger('rost', aRostId);
    params.addInteger('width', aWidth);
    params.addInteger('height', aHeight);
    params.addString('strategy', cStrategy);
    params.addBoolean('embeddedinfo', aEmbeddedInfo);
    if fHTTP.get('/mapicon', params, aStream) then
    begin
      try
        result := aStream;
        try
          aStream.Position  := 0;
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
      raise EHTTPError.Create('get for "/mapsinfo" simply failed.');
    end;
  finally
    FreeAndNil(params);
  end;
end;

function THTTPMDSClient.getMapIcon(aRotId, aRostId : Integer; aWidth, aHeight : Integer; aStrategy : THTTPMDSClientStretchStrategy = HTTPMDSMISS_STRETCH; aEmbeddedInfo : Boolean = false) : TStream;
var ms : THTTPMDSDefaultStream;
begin
  ms  := THTTPMDSDefaultStream.Create;
  try
    result := getMapIcon(aRotId, aRostId, aWidth, aHeight, ms, aStrategy, aEmbeddedInfo);
  finally
    //FreeAndNil(ms);
  end;
end;



initialization
  initXMLSchemaDataTypesV2FormatSettings(MapServerFS);

finalization


end.
