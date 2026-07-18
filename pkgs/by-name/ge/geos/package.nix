{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  cmake,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "geos";
  version = "3.14.1";

  src = fetchFromGitHub {
    owner = "libgeos";
    repo = "geos";
    tag = finalAttrs.version;
    hash = "sha256-lOf14Qva/bbbiywbSE7GbkDQftjY0RudTOaqjllnsj4=";
  };

  nativeBuildInputs = [ cmake ];

  # https://github.com/libgeos/geos/issues/930
  cmakeFlags = lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64) [
    "-DCMAKE_CTEST_ARGUMENTS=--exclude-regex;unit-geom-Envelope"
  ];

  doCheck = true;

  passthru.tests = {
    geos = callPackage ./tests.nix { geos = finalAttrs.finalPackage; };
    pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
  };

  meta = {
    description = "C/C++ library for computational geometry with a focus on algorithms used in geographic information systems (GIS) software";
    homepage = "https://libgeos.org";
    changelog = "https://github.com/libgeos/geos/releases/tag/${finalAttrs.finalPackage.version}";
    license = lib.licenses.lgpl21Only;
    mainProgram = "geosop";
    pkgConfigModules = [ "geos" ];
    teams = [ lib.teams.geospatial ];
  };
})
