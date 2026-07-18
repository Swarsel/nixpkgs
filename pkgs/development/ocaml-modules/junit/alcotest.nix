{
  lib,
  alcotest,
  buildDunePackage,
  junit,
  ocaml,
}:

buildDunePackage {
  inherit (junit) src version meta;
  pname = "junit_alcotest";

  propagatedBuildInputs = [
    junit
    alcotest
  ];

  doCheck = lib.versionAtLeast ocaml.version "4.12";
}
