unit uhttpmdsbase;
// Hier alles reinpacken, was für die Kommunikation notwendig ist,
// nicht in uroutecalculation.pas gehört und identisch auf dem Server vorhanden ist:
// ugeocoding.pas
// MapSourceBase.pas
// (weitere?)

interface

uses SysUtils, Classes

{$IF Defined(ANDROID) or Defined(IOS)}
, System.Generics.Collections
{$ENDIF}
;


type

  // Exception
  EHTTPCode = class (Exception)
  private
    fResponseCode : Integer;
  public
    constructor Create(ErrorMessage : String; responseCode : Integer);
    property ResponseCode : Integer read fResponseCode;
  end;

  EParseError = class (Exception)
  private
    fStreamParsing : TStream;
    fFreeParsingStream : Boolean;
  public
    constructor Create(const Msg: string; const astreamparsing : TStream; const afreeparsingstream : boolean = true);
    destructor Destroy; override;

    property StreamParsing : TStream read fStreamParsing write fStreamParsing;
  end;

  EHTTPError = class (Exception)
  private

  public
    
  end;

  {$IF Defined(ANDROID) or Defined(IOS)}
  THTTPMDSList = TList<TObject>;
  {$ELSE}
  THTTPMDSList = TList;
  {$ENDIF}

  THTTPMDSDefaultStream = TMemoryStream;

  THTTPConnectorResult = class
  protected
    fFromStream     : TStream;
    fIsFromStream   : Boolean;
    fFreeStream     : Boolean;
    fCopyStream     : Boolean;

    procedure internalLoadFromStream; virtual; abstract;
  public
    constructor Create(CopyStreamOnLoad : Boolean = false); reintroduce; virtual;
    destructor Destroy; override;

    procedure clear; virtual;
    procedure loadFromStream(ms: TStream);

    property FromStream : TStream read fFromStream;
    property IsFromStream : Boolean read fIsFromStream;
    property FreeStream : Boolean read fFreeStream write fFreeStream;
    property CopyStream : Boolean read fCopyStream;
  end;

  THTTPConnectorParam= class
  private
    fname: String; // param name
  public
    function getAsText : String; virtual;
    property Name: String read fname write fname;
  end;

  THTTConnectorParamInteger= class(THTTPConnectorParam)
  private
    fValue: Integer;
  public
    function getAsText : String; override;
    property Value: Integer read fValue write fValue;
  end;

  THTTConnectorParamString= class(THTTPConnectorParam)
  private
    fValue: String;
  public
    function getAsText : String; override;
    property Value: String read fValue write fValue;
  end;

  THTTConnectorParamInt64= class(THTTPConnectorParam)
  private
    fValue: Int64;
  public
    function getAsText : String; override;
    property Value: Int64 read fValue write fValue;
  end;

  THTTConnectorParamBoolean= class(THTTPConnectorParam)
  private
    fValue: Boolean;
  public
    function getAsText : String; override;
    property Value: Boolean read fValue write fValue;
  end;

  THTTConnectorParamDouble= class(THTTPConnectorParam)
  private
    fValue: Double;
  public
    function getAsText : String; override;
    property Value: Double read fValue write fValue;
  end;

  THTTConnectorParamDateTime= class(THTTPConnectorParam)
  private
    fValue: TDateTime;
  public
    function getAsText : String; override;
    property Value: TDateTime read fValue write fValue;
  end;


  THTTPConnectorParams = class
  private
    fParams: THTTPMDSList;
  protected
    function getAsText : String; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    procedure clear;
    function  addString(aName: String; aValue: String):boolean;
    function  addFloat(aName: String; aValue: Double):boolean;
    function  addDateTime(aName: String; aValue: TDate):boolean;
    function  addInteger(aName: String; aValue: Integer):boolean;
    function  addInt64(aName: String; aValue: Int64):boolean;
    function  addBoolean(aName: String; aValue: Boolean):boolean;
    function  paramExists(aParam: String): Boolean;

    property AsText : String read getAsText;
  end;

  THTTPConnector  = class(TComponent)
  private
    fBaseURL: String;
    fUserName: String;
    fPassword: String;
    fReadTimeout: Integer;
    fConnectTimeout : Integer;
  public
    constructor Create(AOwner : TComponent); overload; override;
    constructor Create(const aBaseURL, aUsername, aPasswd: String; aReadTimeout : Integer = 30000); overload; virtual;
    destructor Destroy; override;

    function  connectURL(aBase, aCommand : String) : String; virtual;

    procedure initialize(const aBaseURL, aUsername, aPasswd: String; aReadTimeout : Integer = 30000; aConnectTimeout : Integer = 30000); virtual;
    function  getStream(afunction: string; aParams: THTTPConnectorParams): TStream; virtual; abstract;
    function  postStream(afunction: string; aParams: THTTPConnectorParams; aPostStream : TStream): TStream; virtual; abstract;
    function  get(afunction: string; aParams: THTTPConnectorParams; aStreamTo : TStream): Boolean; virtual; abstract;
    function  post(afunction: string; aParams: THTTPConnectorParams; aPostStream : TStream; aStreamTo : TStream): Boolean; virtual; abstract;
    function  createParams: THTTPConnectorParams; virtual;
  end;

  THTTPConnectorId = class (THTTPConnector)
  private

  public
    function  getStream(afunction: string; aParams: THTTPConnectorParams): TStream; override;
    function  postStream(afunction: string; aParams: THTTPConnectorParams; aPostStream : TStream): TStream; override;
    function  get(afunction: string; aParams: THTTPConnectorParams; aStreamTo : TStream): Boolean; override;
    function  post(afunction: string; aParams: THTTPConnectorParams; aPostStream : TStream; aStreamTo : TStream): Boolean; override;
  end;


procedure clearList(aList : THTTPMDSList);


var

  HTTPMDSFormatSettings : TFormatSettings;


implementation

uses IdHTTP, IdURI;

procedure clearList(aList : THTTPMDSList);
var
  i: Integer;  o : TObject;
begin
  if aList <> nil then
  begin
    for i := 0 to aList.Count - 1 do
    begin
      o := aList[i];
      aList[i] := nil;
      FreeAndNil(o);
    end;
    aList.Clear;
  end;
end;


procedure initHTTPMDSFormatSettings(var FormatSettings : TFormatSettings);
begin
  with FormatSettings do
  begin
    CurrencyFormat:=3;
    NegCurrFormat:=8;
    ThousandSeparator:=',';
    DecimalSeparator:='.';
    CurrencyDecimals:=2;
    DateSeparator:='.';
    TimeSeparator:=':';
    ListSeparator:=';';
    CurrencyString:='€';
    ShortDateFormat:='dd.MM.yyyy';
    LongDateFormat:='dddd, d. MMMM yyyy';
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

// ****************************************************************************
// ***** THTTPConnectorParams *************************************************
// ****************************************************************************


constructor THTTPConnectorParams.create;
begin
  inherited create;
  fParams:= THTTPMDSList.Create;
end;


destructor THTTPConnectorParams.Destroy;
begin
  Clear;
  FreeAndNil(fParams);
  inherited Destroy;
end;

// build param string using fParams list
function THTTPConnectorParams.getAsText: String;
var tstr: String;
  i: integer;
begin
  tstr := '';
  for i := 0 to fParams.Count - 1 do
  begin
    if i = 0 then
    begin
      tstr:= '?' + THTTPConnectorParam(fParams[i]).getAsText;
    end else
    begin
      tstr:= tstr + '&' + THTTPConnectorParam(fParams[i]).getAsText;
    end;
  end;
  result:= tstr;
end;

// clear fParams list
procedure THTTPConnectorParams.Clear;
var i: Integer; o : TObject;
begin
  for i := 0 to fParams.Count - 1 do
  begin
    o := TObject(fParams[i]);
    fParams[i] := nil;
    FreeAndNil(o);
  end;
  fParams.Clear;
end;

// returns true if aParam exists in the fParams list
function  THTTPConnectorParams.paramExists(aParam: String): Boolean;
var i: Integer;
begin
  result:= False;
  for i := 0 to fParams.Count - 1 do
  begin
    if LowerCase(THTTPConnectorParam(fParams[i]).Name) = LowerCase(aParam) then
    begin
      result:= True;
      exit;
    end;
  end;
end;


function  THTTPConnectorParams.addString(aName: String; aValue: String):boolean;
var newparam : THTTConnectorParamString;
begin
  if not paramExists(aName) then
  begin
    newparam := THTTConnectorParamString.Create;
    newparam.Name := aName;
    newparam.Value := aValue;
    fParams.Add(newparam);
    result := true;
  end else
    result:=false;
end;

function  THTTPConnectorParams.addFloat(aName: String; aValue: Double):boolean;
var newparam : THTTConnectorParamDouble;
begin
  if not paramExists(aName) then
  begin
    newparam := THTTConnectorParamDouble.Create;
    newparam.Name := aName;
    newparam.Value := aValue;
    fParams.Add(newparam);
    result := true;
  end else
  begin
    result:=false;
  end;
end;

function  THTTPConnectorParams.addDateTime(aName: String; aValue: TDate):boolean;
var newparam : THTTConnectorParamDateTime;
begin
  if not paramExists(aName) then
  begin
    newparam := THTTConnectorParamDateTime.Create;
    newparam.Name := aName;
    newparam.Value := aValue;
    fParams.Add(newparam);
    result := true;
  end else
  begin
      result:=false;
  end;
end;

function  THTTPConnectorParams.addInteger(aName: String; aValue: Integer):boolean;
var newparam : THTTConnectorParamInteger;
begin
  if not paramExists(aName) then
  begin
    newparam := THTTConnectorParamInteger.Create;
    newparam.Name := aName;
    newparam.Value := aValue;
    fParams.Add(newparam);
    result := true;
  end else
  begin
    result := false;
  end;
end;

function  THTTPConnectorParams.addInt64(aName: String; aValue: Int64):boolean;
var newparam : THTTConnectorParamInt64;
begin
  if not paramExists(aName) then
  begin
    newparam := THTTConnectorParamInt64.Create;
    newparam.Name := aName;
    newparam.Value := aValue;
    fParams.Add(newparam);
    result := true;
  end else
  begin
    result:=false;
  end;
end;

function  THTTPConnectorParams.addBoolean(aName: String; aValue: Boolean):boolean;
var newparam : THTTConnectorParamBoolean;
begin
  if not paramExists(aName) then
  begin
    newparam := THTTConnectorParamBoolean.Create;
    newparam.Name := aName;
    newparam.Value := aValue;
    fParams.Add(newparam);
    result := true;
  end else
  begin
    result:=false;
  end;
end;

// ***** EHTTPCode ************************************************************
constructor EHTTPCode.Create(ErrorMessage : String; responseCode : Integer);
begin
  inherited Create(ErrorMessage);
  fResponseCode := responseCode;
end;

// *** THTTPConnector *********************************************************
constructor THTTPConnector.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  initialize('', '', '', 30000);
end;

constructor THTTPConnector.Create(const aBaseURL, aUsername, aPasswd: String; aReadTimeout : Integer = 30000);
begin
  inherited create(nil);
  initialize( aBaseURL, aUsername, aPasswd, aReadTimeout); // THTTPConnector.initialize wird hier nicht ausgeführt, wenn aReadTimeout nicht angegeben?
end;

function THTTPConnector.createParams: THTTPConnectorParams;
begin
  result:= THTTPConnectorParams.Create;
end;

destructor THTTPConnector.Destroy;
begin
  inherited destroy;
end;

function  THTTPConnector.connectURL(aBase, aCommand : String) : String;
var havesl : boolean;
begin
  if aBase <> '' then
  begin
    {$if CompilerVersion > 23}
    if aBase.Chars[length(aBase)-1] = '/' then
    begin
      havesl  := true;
    end else
    begin
      havesl  := false;
    end;
    if havesl then
    begin
      if aCommand <> '' then
      begin
        if aCommand.Chars[0] = '/' then
        begin
          // Slash an Base, und an Command
          result  := aBase + Copy(aCommand, 1, length(aCommand)-1);
        end else
        begin
          // Slash an Base, nicht an Command
          result  := aBase + aCommand;
        end;
      end else
      begin
        result  := aBase;
      end;
    end else
    begin
      if aCommand <> '' then
      begin
        if aCommand.Chars[0] = '/' then
        begin
          // Slash nicht an Base, aber an Command
          result  := aBase + aCommand;
        end else
        begin
          // Slash nicht an Base, und nicht an Command
          result  := aBase + '/' + aCommand;
        end;
      end else
      begin
        result  := aBase + '/';
      end;
    end;
    {$else}
    if aBase[length(aBase)] = '/' then
    begin
      havesl  := true;
    end else
    begin
      havesl  := false;
    end;
    if havesl then
    begin
      if aCommand <> '' then
      begin
        if aCommand[1] = '/' then
        begin
          // Slash an Base, und an Command
          result  := aBase + Copy(aCommand, 2, length(aCommand)-1);
        end else
        begin
          // Slash an Base, nicht an Command
          result  := aBase + aCommand;
        end;
      end else
      begin
        result  := aBase;
      end;
    end else
    begin
      if aCommand <> '' then
      begin
        if aCommand[1] = '/' then
        begin
          // Slash nicht an Base, aber an Command
          result  := aBase + aCommand;
        end else
        begin
          // Slash nicht an Base, und nicht an Command
          result  := aBase + '/' + aCommand;
        end;
      end else
      begin
        result  := aBase + '/';
      end;
    end;
    {$ifend}
  end else
  begin
    result  := aCommand;
  end;
end;

procedure THTTPConnector.initialize(const aBaseURL, aUsername, aPasswd: String; aReadTimeout : Integer = 30000; aConnectTimeout : Integer = 30000);
begin
  fBaseURL:= aBaseURL;
  fUserName:= aUsername;
  fPassword:= aPasswd;
  fReadTimeout:= aReadTimeout;
  fConnectTimeout := aConnectTimeout;
end;

// *** THTTPConnectorID *******************************************************
// *** THTTPConnector with use of Indy Components *****************************

function  THTTPConnectorId.getStream(afunction: string; aParams: THTTPConnectorParams): TStream;
var
  cIdHTTP   : TIdHTTP;
  cURL      : String;
  cParams   : String;
begin
  result := TMemoryStream.Create;
  cIdHTTP := TIdHTTP.Create;
  cIdHTTP.ProtocolVersion := pv1_1;
  cIdHTTP.ReadTimeout := fReadTimeout;
  cIdHTTP.ConnectTimeout  := fConnectTimeout;
  if (fUsername <> '') and (fPassword <> '') then
  begin
    cIdHTTP.Request.Username := fUsername;
    cIDHTTP.Request.Password := fPassword;
    cIdHTTP.Request.BasicAuthentication := true;
  end;
  cParams := aParams.AsText;
  try
    cURL  := connectURL(fBaseURL, afunction) + cParams;
    cURL := cIdHTTP.URL.URLEncode(cURL);
    try
      cIdHTTP.Get(cURL, result);
    except
      on e : exception do
      begin
        FreeAndNil(result);
        raise EHTTPCode.Create('HTTP-Request (Get) failed: ' + e.Message, cIdHTTP.ResponseCode);
      end;
    end;
  finally
    FreeAndNil(cIdHTTP);
  end;
end;

function  THTTPConnectorId.postStream(afunction: string; aParams: THTTPConnectorParams; aPostStream : TStream): TStream;
var
  cIdHTTP   : TIdHTTP;
  cURL      : String;
  cParams   : String;
begin
  result := TMemoryStream.Create;
  cIdHTTP := TIdHTTP.Create;
  cIdHTTP.ProtocolVersion := pv1_1;
  cIdHTTP.ReadTimeout := fReadTimeout;
  cIdHTTP.ConnectTimeout  := fConnectTimeout;
  if (fUsername <> '') and (fPassword <> '') then
  begin
    cIdHTTP.Request.Username := fUsername;
    cIDHTTP.Request.Password := fPassword;
    cIdHTTP.Request.BasicAuthentication := true;
  end;
  cParams := aParams.AsText;
  try
    cURL  := connectURL(fBaseURL, afunction) + cParams;
    cURL := cIdHTTP.URL.URLEncode(cURL);
    try
      cIdHTTP.Post(cURL, aPostStream, result);
    except
      on e : exception do
      begin
        FreeAndNil(result);
        raise EHTTPCode.Create('HTTP-Request (Post) failed: ' + e.Message, cIdHTTP.ResponseCode);
      end;
    end;
  finally
    FreeAndNil(cIdHTTP);
  end;
end;

function  THTTPConnectorId.get(afunction: string; aParams: THTTPConnectorParams; aStreamTo : TStream): Boolean;
var
  cIdHTTP   : TIdHTTP;
  cURL      : String;
  cParams   : String;
begin
  result := false;
  cIdHTTP := TIdHTTP.Create;
  cIdHTTP.ProtocolVersion := pv1_1;
  cIdHTTP.ReadTimeout := fReadTimeout;
  cIdHTTP.ConnectTimeout  := fConnectTimeout;
  if (fUsername <> '') and (fPassword <> '') then
  begin
    cIdHTTP.Request.Username := fUsername;
    cIDHTTP.Request.Password := fPassword;
    cIdHTTP.Request.BasicAuthentication := true;
  end;
  cParams := aParams.AsText;
  try
    //cURL := fBaseURL + afunction + cParams;
    cURL  := connectURL(fBaseURL, afunction) + cParams;
    cURL := cIdHTTP.URL.URLEncode(cURL);
    try
      cIdHTTP.Get(cURL, aStreamTo);
      result := true;
    except
      on e : exception do
      begin
        raise EHTTPCode.Create('HTTP-Request (Get) failed: ' + e.Message, cIdHTTP.ResponseCode);
      end;
    end;
  finally
    FreeAndNil(cIdHTTP);
  end;
end;

function  THTTPConnectorId.post(afunction: string; aParams: THTTPConnectorParams; aPostStream : TStream; aStreamTo : TStream): Boolean;
var
  cIdHTTP   : TIdHTTP;
  cURL      : String;
  cParams   : String;
begin
  result := false;
  cIdHTTP := TIdHTTP.Create;
  cIdHTTP.ProtocolVersion := pv1_1;
  cIdHTTP.ReadTimeout := fReadTimeout;
  cIdHTTP.ConnectTimeout  := fConnectTimeout;
  if (fUsername <> '') and (fPassword <> '') then
  begin
    cIdHTTP.Request.Username := fUsername;
    cIDHTTP.Request.Password := fPassword;
    cIdHTTP.Request.BasicAuthentication := true;
  end;
  cParams := aParams.AsText;
  try
    cURL  := connectURL(fBaseURL, afunction) + cParams;
    cURL  := cIdHTTP.URL.URLEncode(cURL);
    try
      cIdHTTP.Post(cURL, aPostStream, aStreamTo);
      result := true;
    except
      on e : exception do
      begin
        raise EHTTPCode.Create('HTTP-Request (Post) failed: ' + e.Message, cIdHTTP.ResponseCode);
      end;
    end;
  finally
    FreeAndNil(cIdHTTP);
  end;
end;

{ THTTPConnectorParam }
function THTTPConnectorParam.getAsText: String;
begin
  result := fname + '=';
end;

{ THTTConnectorParamInteger }
function THTTConnectorParamInteger.getAsText: String;
begin
  result := inherited getAsText + IntToStr(fValue);
end;

{ THTTConnectorParamInt64 }
function THTTConnectorParamInt64.getAsText: String;
begin
  result := inherited getAsText + IntToStr(fValue);
end;

{ THTTConnectorParamBoolean }
function THTTConnectorParamBoolean.getAsText: String;
begin
  result := inherited getAsText + BoolToStr(fValue, true);
end;

{ THTTConnectorParamString }
function THTTConnectorParamString.getAsText: String;
begin
  result := inherited getAsText + fValue;
end;

{ THTTConnectorParamDouble }
function THTTConnectorParamDouble.getAsText: String;
begin
  result := inherited getAsText + FloatToStrF(Value, ffFixed,15,8, HTTPMDSFormatSettings);
end;

{ THTTConnectorParamDateTime }
function THTTConnectorParamDateTime.getAsText: String;
begin
  result := inherited getAsText + DateTimeToStr(Value, HTTPMDSFormatSettings);
end;


{ THTTPConnectorResult }

procedure THTTPConnectorResult.clear;
begin
  if fFreeStream then
  begin
    FreeAndNil(fFromStream);
  end else
  begin
    fFromStream := nil;
  end;
  fIsFromStream := false;
end;

constructor THTTPConnectorResult.Create(CopyStreamOnLoad : Boolean = false);
begin
  inherited Create;
  fFromStream     := nil;
  fIsFromStream   := false;
  fFreeStream     := true;
  fCopyStream     := CopyStreamOnLoad;
end;

destructor THTTPConnectorResult.Destroy;
begin
  clear;
  inherited;
end;

procedure THTTPConnectorResult.loadFromStream(ms: TStream);
begin
  if fFromStream = nil then
  begin
    if fCopyStream then
    begin
      fFromStream := TMemoryStream.Create;
      fFromStream.CopyFrom(ms, ms.Size);
      fIsFromStream := true;
    end else
    begin
      fFromStream := ms;
      fIsFromStream := true;
    end;
    internalLoadFromStream;
  end else
  begin
    raise EHTTPError.Create('cannot load a result from stream, where always a result is in this object. try clear() first.');
  end;
end;

{ EParseError }

constructor EParseError.Create(const Msg: string; const astreamparsing : TStream; const afreeparsingstream : boolean = true);
begin
  inherited Create(Msg);
  fStreamParsing := astreamparsing;
  fFreeParsingStream := afreeparsingstream;
end;

destructor EParseError.Destroy;
begin
  if fFreeParsingStream then
  begin
    FreeAndNil(fStreamParsing);
  end;
  inherited Destroy;
end;

initialization

  initHTTPMDSFormatSettings(HTTPMDSFormatSettings);

finalization


end.




