unit uhttpmdsmapelementbase;

interface

const

  ROTID_STARTFORBASICOBJECTS = 20;

  // Straﬂennetz...
  ROTID_ROADS = ROTID_STARTFORBASICOBJECTS;
  ROSTID_ROADELEMENTS = 1;
  ROSTID_ROADJUNCTIONS = 2;
  ROSTID_ROADINTERSECTIONS = 3;
  ROSTID_STREETS = 4;
  ROSTID_STREETCOLLECTIONS = 5;
  ROSTID_PSEUDOROADELEMENTS = 6;
  ROSTID_LINKELEMENTS = 7;
  ROSTID_LINKELEMENTJUNCTIONS = 8;
  ROSTID_TRAFFICCALMING = 9;          // Verkehrsberuhigung
  ROSTID_BUSSTOP = 10;                // Bushaltestelle
  ROSTID_CROSSWALK = 11;              // Zebrastreifen / Fuﬂg‰nger¸berweg
  ROSTID_TRAFFICSIGN = 12;            // Verkehrszeichen
  ROSTID_EMERGENCYPHONE = 13;         // SOS-Telefon
  ROSTID_PASSINGPLACE = 14;           // Ausweichstelle
  ROSTID_SPEEDCAMERA = 15;            // Blitzer
  ROSTID_TRAFFICSIGNALS = 16;         // Ampel
  ROSTID_TURNINGCIRCLE = 17;          // Wendestelle

type

  TRoadType = (RT_UNKNOWN, RT_ROAD, RT_FERRY, RT_TRAIN);

  TConstructionState = (
    CS_UNKNOWN,
    CS_READY,
    CS_UNDERCONSTRUCTION,
    CS_PLANNED
  );

  TFunctionalRoadClass =
  (
    FRC00, FRC01, FRC02, FRC03, FRC04, FRC05, FRC06, FRC07,
    FRC08, FRC09, FRC10, FRC11, FRC12, FRC13, FRC14, FRC15
  );

  TFormOfWay = (
    FOW_Unknown,
    FOW_Motorway,
    FOW_MultipleCarriagewayWhichIsNotAMotorway,
    FOW_SingleCarriageway, FOW_Roundabout,
    FOW_TrafficSquare, FOW_ParkingPlace,
    FOW_ParkingBuilding, FOW_UnstructuredTrafficSquare,
    FOW_AnotherTypeOfEnclosedTrafficArea, FOW_SlipRoad,
    FOW_ServiceRoad, FOW_EntranceExitOfCarPark,
    FOW_EntranceExitOfService, FOW_PedestrianZone,
    FOW_Walkway,          // not passable for vehicles
    FOW_SpecialTrafficFigure,
    FOW_RoadForAuthorities,
    FOW_MotorwaySlipRoad // Straﬂen eines Autobahnkreuzes die nicht Autobahn selbst sind
  );
  TBlockedPassage = (
    BP_None,            // keine Blockade im Straﬂenelement
    BP_AtStartJunction, // Blockade an der Startkreuzung
    BP_AtEndJunction,   // Blockade an der Endkreuzung
    BP_BetweenJunctions // Blockade irgendwo dazwischen (Position siehe Attribut ???)
  );

  TMainDirectionFlow = (
    DF_Unknown,  // kein Eintrag in Karten (In beide Richtungen befahrbar)
    DF_None,     // nicht befahrbar, in keine der beiden Richtungen
    DF_Positive, // von Start- zu Endjunction
    DF_Negative, // von End- zu StartJunction
    DF_Both
  );

  TMapElementType = (
    TNaMRORoadElement,
    TNaMRORoadElementJunction,
    TNaMROIntersection,
    TNaMROStreet,
    TNaMROStreetCollection,
    TNaMROAdministrativeInfo,
    TNaMROServicePoint,
    TNaMROArea,
    TNaMRORailwayElement,
    TNaMROBasicLine,
    TNaMROParcel,
    TNaMROBTName,
    TNaMROROTROSTMetaInfo
  );

implementation

end.
