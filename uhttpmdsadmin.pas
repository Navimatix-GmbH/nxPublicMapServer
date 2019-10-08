unit uhttpmdsadmin;

interface

uses types, classes, SysUtils, XMLIntf, XMLDoc, uhttpmdsbase;

const  // Admin Commands analog WebRequestHandler.pas...
  WMCMD_ADMIN_LOADSETTINGS                = '/_admin_loadsettings';
  WMCMD_ADMIN_SETLOGGING                  = '/_admin_setlogging';
  WMCMD_ADMIN_COMMITTRANSACTIONS          = '/_admin_committransactions';
  WMCMD_ADMIN_RESTARTSERVICE              = '/_admin_restartservice';
  WMCMD_ADMIN_RESTARTMACHINE              = '/_admin_restartmachine';
  WMCMD_ADMIN_USERS                       = '/_admin_users';
  WMCMD_ADMIN_USERADD                     = '/_admin_useradd';
  WMCMD_ADMIN_USERUPDATE                  = '/_admin_userupdate';
  WMCMD_ADMIN_USERDELETE                  = '/_admin_userdelete';
  WMCMD_ADMIN_REQUESTCOUNTS               = '/_admin_requestcounts';

  // ? to be added ?
  // WMCMD_ADMIN_REQUESTSALLOWED             = '/_admin_requestsallowed';
  // WMCMD_ADMIN_REQUESTALLOWED              = '/_admin_requestallowed';

type

  THTTPMDSAdminUser = class
  private
    fId               : Int64;
    fUsername         : String;
    fPassword         : String;
    fUserType         : Integer;
    fActive           : Boolean;
    fExpirationDate   : TDateTime;
    fAdditionalNumber : Int64;
    fAdditionalIdent  : String;
  public
    constructor Create;
    destructor Destroy; override;
    procedure parseFromXML(aBaseNode : IXMLNode); virtual;

    class function loadFromStreamToList(const aFromStream : TStream; aToList : THTTPMDSList) : Boolean;

    property Id               : Int64 read fId write fId;
    property Username         : String read fUsername write fUsername;
    property Password         : String read fPassword write fPassword;
    property UserType         : Integer read fUserType write fUserType;
    property Active           : Boolean read fActive  write  fActive;
    property ExpirationDate   : TDateTime read fExpirationDate write fExpirationDate;
    property AdditionalNumber : Int64 read fAdditionalNumber write fAdditionalNumber;
    property AdditionalIdent  : String read fAdditionalIdent write fAdditionalIdent;
  end;

  THTTPMDSAdminRequestCountGroup = class
  private
    fGroup        : String;
    fName         : String;
    fCount        : Integer;

  public
    property Group         : String read fGroup write fGroup;
    property Name          : String read fName write fName;
    property Count         : Integer read fCount write fCount;
  end;

  THTTPMDSAdminRequestCount = class
  private
    fCount        : Integer;
    fgroupList    : THTTPMDSList;

  public
    constructor Create;
    destructor Destroy; override;
    procedure parseXMLRequestCount(aBaseNode : IXMLNode); virtual;

    procedure loadFromStreamToList(const aFromStream : TStream); virtual;

    property Count         : Integer read fCount write fCount;
    property GroupList     : THTTPMDSList read fgroupList write fgroupList;
  end;


// HTTP-Servie-Admin
  THTTPMDSAdmin = class (TComponent)
  private
    fHTTP                 : THTTPConnector;
  protected

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function  getAllUsers(aToList : THTTPMDSList; aStream : TStream) : Boolean; overload; virtual;
    function  getAllUsers(aToList : THTTPMDSList) : Boolean; overload; virtual;
    procedure addUser(aUser : THTTPMDSAdminUser); virtual;
    procedure deleteUser(aId : Int64); virtual;
    procedure updateUser(aUser : THTTPMDSAdminUser); virtual;
    function  rebootMachine(aMachineKey: String) : Boolean; virtual;
    function  restartService(aServiceKey: String) : Boolean; virtual;
    procedure setLogging; virtual;
    function  loadSettings: Boolean; virtual;
    function  commitTransactions: Boolean; virtual;
    function  requestcounts(account : String; accountId : int64; fromDay, toDay : TDate; group : String; aStream : TStream) : THTTPMDSAdminRequestCount; overload; virtual;
    function  requestcounts(account : String; accountId : int64; fromDay, toDay : TDate; group : String) : THTTPMDSAdminRequestCount; overload; virtual;

  published
    property HTTP : THTTPConnector read fHTTP write fHTTP;

  end;


implementation

uses Math;


constructor THTTPMDSAdminUser.Create;
begin
  inherited;
  fId               := 0;
  fUsername         := '';
  fPassword         := '';
  fUserType         := 0;
  fActive           := false;
  fExpirationDate   := NaN;
  fAdditionalNumber := 0;
  fAdditionalIdent  := '';
end;

destructor THTTPMDSAdminUser.Destroy;
begin
  inherited;
end;

procedure THTTPMDSAdminUser.parseFromXML(aBaseNode : IXMLNode);
begin
  fId := StrToInt64(aBaseNode.Attributes['id']);
  fUsername := aBaseNode.Attributes['name'];
  fPassword := aBaseNode.Attributes['pwd'];
  fUserType := aBaseNode.Attributes['type'];
  fActive := StrToBoolDef(aBaseNode.Attributes['active'], false);
  fExpirationDate := StrToDateTimeDef(aBaseNode.Attributes['expiration'], 0, HTTPMDSFormatSettings);
  fAdditionalNumber := StrToInt64Def(aBaseNode.Attributes['extraid'], 0);
  fAdditionalIdent  := aBaseNode.Attributes['extraidend'];
end;

class function THTTPMDSAdminUser.loadFromStreamToList(const aFromStream : TStream; aToList : THTTPMDSList) : Boolean;
var cXMLdoc   : IXMLDocument;
    cRootNode, cUsersNode : IXMLNode;
    i         : Integer;
    cuser     : THTTPMDSAdminUser;
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

    cRootNode := cXMLDoc.ChildNodes.FindNode('namhttpservice');
    if cRootNode = nil then
    begin
      // nix für uns...
      raise Exception.Create('XML-Parser failed: ' + 'expecting node "namhttpservice"');
    end;
    cUsersNode  := cRootNode.ChildNodes.FindNode('users');
    if cUsersNode <> nil then
    begin
      try
        for i := 0 to cUsersNode.ChildNodes.Count - 1 do
        begin
          try
            cuser := THTTPMDSAdminUser.Create;
            cuser.parseFromXML(cUsersNode.ChildNodes.Get(i));
            aToList.add(cuser);
          except
            on e : Exception do
            begin
              FreeAndNil(cuser);
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
      raise Exception.Create('no users avaliable');
      result := false;
    end;
  finally
    cXMLDoc := nil;
  end;
end;


{ THTTPMDSAdmin }

constructor THTTPMDSAdmin.Create(AOwner: TComponent);
begin
  inherited;
  fHTTP := nil;
end;

destructor THTTPMDSAdmin.Destroy;
begin
  fHTTP := nil;
  inherited;
end;

procedure THTTPMDSAdmin.addUser(aUser: THTTPMDSAdminUser);
var params : THTTPConnectorParams; ms  : THTTPMDSDefaultStream;
begin
  if fHTTP = nil then
  begin
    raise EHTTPError.Create('can not perform action if http connector ist not assigned!');
  end;

  params := fHTTP.createParams;
  ms  := THTTPMDSDefaultStream.Create;
  try
    // Parameter...
    params.addString('name', aUser.Username);
    params.addString('pwd', aUser.Password);
    if aUser.Active
      then params.addString('active', 'true')
      else params.addString('active', 'false');
    params.addInteger('type', auser.UserType);
    params.addDateTime('expiration', aUser.ExpirationDate);
    params.addInt64('extraid', aUser.AdditionalNumber);

    if fHTTP.get(WMCMD_ADMIN_USERADD, params, ms) then
    begin
      //
    end else
    begin
      raise EHTTPError.Create('get for "'+WMCMD_ADMIN_USERADD+'" simply failed.');
    end;
  finally
    FreeAndNil(params);
    FreeAndNil(ms);
  end;
end;

procedure THTTPMDSAdmin.deleteUser(aId: Int64);
var params : THTTPConnectorParams; ms  : THTTPMDSDefaultStream;
begin
  if fHTTP = nil then
  begin
    raise EHTTPError.Create('can not perform action if http connector ist not assigned!');
  end;

  params := fHTTP.createParams;
  ms  := THTTPMDSDefaultStream.Create;
  try
    // Parameter...
    params.addInteger('id', aId);
    if fHTTP.get(WMCMD_ADMIN_USERDELETE, params, ms) then
    begin

    end else
    begin
      raise EHTTPError.Create('get for "'+WMCMD_ADMIN_USERDELETE+'" simply failed.');
    end;
  finally
    FreeAndNil(params);
    FreeAndNil(ms);
  end;

end;

function  THTTPMDSAdmin.getAllUsers(aToList : THTTPMDSList; aStream : TStream) : Boolean;
var params : THTTPConnectorParams;
begin
  result:= true;
  if fHTTP = nil then
  begin
    raise EHTTPError.Create('can not perform "'+WMCMD_ADMIN_USERS+'" if http connector ist not assigned!');
  end;

  params := fHTTP.createParams;
  try
    // keine Parameter...
    if fHTTP.get(WMCMD_ADMIN_USERS, params, aStream) then
    begin
      try
        try
          result  := THTTPMDSAdminUser.loadFromStreamToList(aStream, aToList);
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
      raise EHTTPError.Create('get for "'+WMCMD_ADMIN_USERS+'" simply failed.');
    end;
  finally
    FreeAndNil(params);
  end;
end;

function  THTTPMDSAdmin.getAllUsers(aToList: THTTPMDSList) : Boolean;
var ms : THTTPMDSDefaultStream;
begin
  ms  := THTTPMDSDefaultStream.Create;
  try
    result  := getAllUsers(aToList, ms);
  finally
    FreeAndNil(ms);
  end;
end;

procedure THTTPMDSAdmin.updateUser(aUser: THTTPMDSAdminUser);
var params : THTTPConnectorParams; ms  : THTTPMDSDefaultStream;
begin
  if fHTTP = nil then
  begin
    raise EHTTPError.Create('can not perform "'+WMCMD_ADMIN_USERUPDATE+'" if http connector ist not assigned!');
  end;
  params := fHTTP.createParams;
  ms  := THTTPMDSDefaultStream.Create;
  try
    // Parameter...
    params.addInteger('id', aUser.Id);
    params.addString('name', aUser.Username);
    params.addString('pwd', aUser.Password);
    if aUser.Active
      then params.addString('active', 'true')
      else params.addString('active', 'false');
    params.addInteger('type', auser.UserType);
    params.addDateTime('expiration', aUser.ExpirationDate);
    params.addInt64('extraid', aUser.AdditionalNumber);

    if fHTTP.get(WMCMD_ADMIN_USERUPDATE, params, ms) then
    begin

    end else
    begin
      raise EHTTPError.Create('get for "'+WMCMD_ADMIN_USERUPDATE+'" simply failed.');
    end;
  finally
    FreeAndNil(params);
    FreeAndNil(ms);
  end;
end;

function THTTPMDSAdmin.rebootMachine(aMachineKey: String) : Boolean;
var params : THTTPConnectorParams; ms  : THTTPMDSDefaultStream;
begin
  if fHTTP = nil then
  begin
    raise EHTTPError.Create('can not perform "'+WMCMD_ADMIN_RESTARTMACHINE+'" if http connector ist not assigned!');
  end;
  params := fHTTP.createParams;
  ms  := THTTPMDSDefaultStream.Create;
  try
    // Parameter...
    params.addString('machineaccess', aMachineKey);
    if fHTTP.get(WMCMD_ADMIN_RESTARTMACHINE, params, ms) then
    begin
      result:=true;
    end else
    begin
      result:=false;
      raise EHTTPError.Create('get for "'+ WMCMD_ADMIN_RESTARTMACHINE +'" simply failed.');
    end;
  finally
    FreeAndNil(params);
    FreeAndNil(ms);
  end;
end;


function  THTTPMDSAdmin.restartService(aServiceKey: String) : Boolean;
var params : THTTPConnectorParams; ms  : THTTPMDSDefaultStream;
begin
  if fHTTP = nil then
  begin
    raise EHTTPError.Create('can not perform "'+WMCMD_ADMIN_RESTARTSERVICE+'" if http connector ist not assigned!');
  end;
  params := fHTTP.createParams;
  ms  := THTTPMDSDefaultStream.Create;
  try
    // Parameter...
    params.addString('masteraccess', aServiceKey);
    if fHTTP.get(WMCMD_ADMIN_RESTARTSERVICE, params, ms) then
    begin
      result:=true;
    end else
    begin
      result:=false;
      raise EHTTPError.Create('get for "'+ WMCMD_ADMIN_RESTARTSERVICE +'" simply failed.');
    end;
  finally
    FreeAndNil(params);
    FreeAndNil(ms);
  end;
end;

procedure THTTPMDSAdmin.setLogging;  // possibly params () to be added??
var params : THTTPConnectorParams; ms  : THTTPMDSDefaultStream;
begin
  if fHTTP = nil then
  begin
    raise EHTTPError.Create('can not perform "'+WMCMD_ADMIN_SETLOGGING+'" if http connector ist not assigned!');
  end;
  params := fHTTP.createParams;
  ms  := THTTPMDSDefaultStream.Create;
  try
    if fHTTP.get(WMCMD_ADMIN_SETLOGGING, params, ms) then
    begin

    end else
    begin
      raise EHTTPError.Create('get for "'+ WMCMD_ADMIN_SETLOGGING +'" simply failed.');
    end;
  finally
    FreeAndNil(params);
    FreeAndNil(ms);
  end;
end;


function THTTPMDSAdmin.loadSettings: Boolean;
var params : THTTPConnectorParams; ms  : THTTPMDSDefaultStream;
begin
  if fHTTP = nil then
  begin
    raise EHTTPError.Create('can not perform "'+WMCMD_ADMIN_LOADSETTINGS+'" if http connector ist not assigned!');
  end;
  params := fHTTP.createParams;
  ms  := THTTPMDSDefaultStream.Create;
  try
    if fHTTP.get(WMCMD_ADMIN_LOADSETTINGS, params, ms) then
    begin
      result:=true;
    end else
    begin
      result:=false;
      raise EHTTPError.Create('get for "'+ WMCMD_ADMIN_LOADSETTINGS +'" simply failed.');
    end;
  finally
    FreeAndNil(params);
    FreeAndNil(ms);
  end;
end;

function THTTPMDSAdmin.requestcounts(account: String; accountId: int64; fromDay,
  toDay: TDate; group: String; aStream: TStream): THTTPMDSAdminRequestCount;
var  params : THTTPConnectorParams;
    fromDayStr, toDayStr : String;
    year, month, day : word;
begin
  if fHTTP = nil then
  begin
    raise EHTTPError.Create('can not perform "'+WMCMD_ADMIN_REQUESTCOUNTS+'" if http connector ist not assigned!');
  end;
  DecodeDate(fromDay, year, month, day);
  fromDayStr := Format('%0:s-%1:s-%2:s',[IntToStr(year), IntToStr(month), IntToStr(day)]);
  DecodeDate(toDay, year, month, day);
  toDayStr := Format('%0:s-%1:s-%2:s',[IntToStr(year), IntToStr(month), IntToStr(day)]);

  params := fHTTP.createParams;
  params.addString('account', account);
  params.addInt64('accountid', accountid);
  params.addString('fromday', fromDayStr);
  params.addString('today', toDayStr);
  params.addString('group', group);
  try
    // keine Parameter...
    if fHTTP.get(WMCMD_ADMIN_REQUESTCOUNTS, params, aStream) then
    begin
      try
        Result := THTTPMDSAdminRequestCount.Create;
        try
          result.loadFromStreamToList(aStream);
        except
          on e : exception do
          begin
            raise e;
          end;
        end;
      finally

      end;
    end else
    begin
      raise EHTTPError.Create('get for "'+WMCMD_ADMIN_USERS+'" simply failed.');
    end;
  finally
    FreeAndNil(params);
  end;
end;

function THTTPMDSAdmin.requestcounts(account: String; accountId: int64; fromDay,
  toDay: TDate; group: String): THTTPMDSAdminRequestCount;
var ms : THTTPMDSDefaultStream;
begin
  ms  := THTTPMDSDefaultStream.Create;
  try
    result  := requestcounts(account, accountId, fromDay, toDay, group, ms);
  finally
    FreeAndNil(ms);
  end;
end;

function THTTPMDSAdmin.commitTransactions: Boolean;
var params : THTTPConnectorParams; ms  : THTTPMDSDefaultStream;
begin
  if fHTTP = nil then
  begin
    raise EHTTPError.Create('can not perform "'+WMCMD_ADMIN_COMMITTRANSACTIONS+'" if http connector ist not assigned!');
  end;
  params := fHTTP.createParams;
  ms  := THTTPMDSDefaultStream.Create;
  try
    if fHTTP.get(WMCMD_ADMIN_COMMITTRANSACTIONS, params, ms) then
    begin
      result:=true;
    end else
    begin
      result:=false;
      raise EHTTPError.Create('get for "'+ WMCMD_ADMIN_COMMITTRANSACTIONS +'" simply failed.');
    end;
  finally
    FreeAndNil(params);
    FreeAndNil(ms);
  end;
end;

{
function  THTTPMDSAdmin.requestcounts(account : String; accountId : int64; fromDay, toDay : String; group : String) : Boolean;
var  params : THTTPConnectorParams; ms  : THTTPMDSDefaultStream;
begin
  if fHTTP = nil then
  begin
   raise EHTTPError.Create('can not perform "'+WMCMD_ADMIN_REQUESTCOUNTS+'" if http connector ist not assigned!');
  end;
  params := fHTTP.createParams;
  ms  := THTTPMDSDefaultStream.Create;
  try
    params.addString('account', account);
    params.addInt64('accountid', accountid);
    params.addString('fromday', fromday);
    params.addString('today', toDay);
    params.addString('group', group);
    if fHTTP.get(WMCMD_ADMIN_REQUESTCOUNTS, params, ms) then
    begin
      result:=true;
    end else
    begin
      result:=false;
      raise EHTTPError.Create('get for "'+ WMCMD_ADMIN_REQUESTCOUNTS +'" simply failed.');
    end;
  finally
    FreeAndNil(params);
    FreeAndNil(ms);
  end;

end;
  }


{ THTTPMDSAdminRequestCount }

constructor THTTPMDSAdminRequestCount.Create;
begin
  fCount := -1;
  fgroupList := nil;
end;

destructor THTTPMDSAdminRequestCount.Destroy;
begin
  inherited;
end;

procedure THTTPMDSAdminRequestCount.loadFromStreamToList(
  const aFromStream: TStream);
var cXMLdoc               : IXMLDocument;
    cRootNode, cUsersNode : IXMLNode;
    i                     : Integer;
    cRequestCount         : THTTPMDSAdminRequestCount;
    cNodeList : IXMLNodeList;
    cNode : IXMLNode;
    ccount, crequestcountvalue : integer;
    cgroup, cname : String;
begin
  if (aFromStream = nil)then
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

    cRootNode := cXMLDoc.ChildNodes.FindNode('namhttpservice');
    if cRootNode = nil then
    begin
      // nix für uns...
      raise Exception.Create('XML-Parser failed: ' + 'expecting node "namhttpservice"');
    end;
    cUsersNode  := cRootNode.ChildNodes.FindNode('requestcounts');
    if cUsersNode <> nil then
    begin
      try
        parseXMLRequestCount(cUsersNode);
      except
        on e : Exception do
        begin
          raise Exception.Create('XML-Parser failed: ' + e.Message);
        end;
      end;
    end else
 {   if cUsersNode <> nil then
    begin
      ccount := StrToInt(cUsersNode.Text);
      fcount := ccount;
      try
        for i := 0 to cUsersNode.ChildNodes.Count - 1 do
        begin
          try
            cNodeList := cUsersNode.ChildNodes;
            cNode := cNodeList.Get(i);
            requestcount := StrToInt(cNode.Text);
            frequestcount := requestcount;

            cNode := cUsersNode.ChildNodes.FindNode('group');
            group := cNode.Text;
            fGroup := group;

            cNode := cUsersNode.ChildNodes.FindNode('name');
            Name := cNode.Text;
            fname := name;

            cRequestCount := THTTPMDSAdminRequestCount.Create;
            cRequestCount.parseFromXML(cUsersNode.ChildNodes.Get(i));
            aToList.add(cRequestCount);
          except
            on e : Exception do
            begin
              FreeAndNil(cRequestCount);
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
    end else  }
    begin
      cRootNode := cRootNode.ChildNodes.FindNode('error');
      raise Exception.Create('no users avaliable');
    end;
  finally
    cXMLDoc := nil;
  end;
end;

procedure THTTPMDSAdminRequestCount.parseXMLRequestCount(aBaseNode: IXMLNode);
var
  ccount, requestcount: Integer;
  i : Integer;
  cNodeList : IXMLNodeList;
  cNode : IXMLNode;
  group, name : String;
  request : THTTPMDSAdminRequestCountGroup;
begin
  if aBaseNode <> nil then
  begin
    ccount := StrToInt(aBaseNode.Attributes['count']);
    fcount := ccount;
    fgroupList := THTTPMDSList.Create;
    try
      for i := 0 to aBaseNode.ChildNodes.Count - 1 do
      begin
          request := THTTPMDSAdminRequestCountGroup.Create;

          cNodeList := aBaseNode.ChildNodes;
          cNode := cNodeList.Get(i);
          request.fCount := StrToInt(cNode.Text);

          group := cNode.Attributes['group'];
          request.fGroup := group;

          Name := cNode.Attributes['name'];
          request.fname := name;

          fgroupList.Add(request);
      end;
    except
    on e : Exception do
      begin
       raise Exception.Create('List-Creation failed: ' + e.Message);
      end;
    end;
  end;


 { fGroup := aBaseNode.Attributes['group'];
  fName := aBaseNode.Attributes['name'];
  fRequestcount := aBaseNode.Attributes['requestcount'];
  fCount := aBaseNode.Attributes['count']; }
end;

end.

