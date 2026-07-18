{
  lib,
  stdenv,
  fetchFromGitHub,
  abseil-cpp_202103,
  boost,
  kyotocabinet,
  libmicrohttpd,
  libosmscout,
  libpostal,
  libsForQt5,
  libtiff,
  marisa,
  osrm-backend,
  pkg-config,
  protobuf_21,
  sqlite,
  valhalla,
}:

let
  date = fetchFromGitHub {
    hash = "sha256-Mq7Yd+y8M3JNG9BEScwVEmxGWYEy6gaNNSlTGgR9LB4=";
    owner = "HowardHinnant";
    repo = "date";
    rev = "a45ea7c17b4a7f320e199b71436074bd624c9e15";
  };
  protobuf' = protobuf_21.override {
    abseil-cpp = abseil-cpp_202103.override {
      cxxStandard = "17";
    };
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "osmscout-server";
  version = "3.1.5";

  src = fetchFromGitHub {
    owner = "rinigus";
    repo = "osmscout-server";
    tag = finalAttrs.version;
    hash = "sha256-gmAHX7Gt2oAvTSTCypAjzI5a9TWOPDAYAMD1i1fJVUY=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    libsForQt5.qmake
    pkg-config
    libsForQt5.qttools
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    libsForQt5.qtquickcontrols2
    libsForQt5.qtlocation
    valhalla
    libosmscout
    osrm-backend
    libmicrohttpd
    libpostal
    libtiff
    sqlite
    marisa
    kyotocabinet
    boost
    protobuf'
    date
  ];

  # valhalla 3.6 headers use std::ranges/std::views (C++20).
  env.NIX_CFLAGS_COMPILE = "-std=c++20";

  qmakeFlags = [
    "SCOUT_FLAVOR=qtcontrols"
    "CONFIG+=disable_mapnik" # Disable the optional mapnik backend
  ];

  meta = {
    description = "Maps server providing tiles, geocoder, and router";
    homepage = "https://github.com/rinigus/osmscout-server";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.Thra11 ];
    platforms = lib.platforms.linux;
  };
})
