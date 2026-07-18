{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  ppx_deriving,
  ppxlib,
  qcheck,
}:

let
  param =
    if lib.versionAtLeast ppxlib.version "0.36" then
      {
        version = "0.9";
        hash = "sha256-ToF+bRbiq1P5YaGOKiW//onJDhxaxmnaz9/JbJ82OWM=";
        tag = "v0.91";
      }
    else
      {
        version = "0.6";
        hash = "sha256-iuFlmSeUhumeWhqHlaNqDjReRf8c4e76hhT27DK3+/g=";
        tag = "v0.24";
      };
in

buildDunePackage {
  inherit (param) version;
  pname = "ppx_deriving_qcheck";

  src = fetchFromGitHub {
    inherit (param) tag hash;
    owner = "c-cube";
    repo = "qcheck";
  };

  propagatedBuildInputs = [
    qcheck
    ppxlib
    ppx_deriving
  ];

  meta = qcheck.meta // {
    description = "PPX Deriver for QCheck";
  };
}
