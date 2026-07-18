{
  lib,
  alcotest-lwt,
  astring,
  base64,
  buildDunePackage,
  cmdliner,
  fmt,
  httpaf,
  httpaf-lwt-unix,
  logs,
  magic-mime,
  mirage-crypto,
  mtime,
  multipart-form-data,
  ptime,
  re,
  rock,
  tyxml,
  uri,
  yojson,
}:

buildDunePackage {
  inherit (rock) src version;
  pname = "opium";

  propagatedBuildInputs = [
    astring
    base64
    cmdliner
    fmt
    httpaf
    httpaf-lwt-unix
    logs
    magic-mime
    mirage-crypto
    mtime
    multipart-form-data
    ptime
    re
    rock
    tyxml
    uri
    yojson
  ];

  doCheck = true;

  checkInputs = [
    alcotest-lwt
  ];

  minimalOCamlVersion = "4.08";

  meta = {
    description = "OCaml web framework";
    homepage = "https://github.com/rgrinberg/opium";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.pmahoney ];
    broken = true; # Not compatible with mirage-crypto ≥ 1.0
  };
}
