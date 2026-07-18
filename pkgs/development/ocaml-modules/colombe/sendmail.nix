{
  lib,
  alcotest,
  angstrom,
  base64,
  buildDunePackage,
  colombe,
  hxd,
  ke,
  logs,
  mrmime,
  rresult,
  tls,
}:

buildDunePackage {
  inherit (colombe) version src;
  pname = "sendmail";

  propagatedBuildInputs = [
    base64
    colombe
    logs
    rresult
    hxd
    ke
    tls
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    mrmime
  ];

  meta = colombe.meta // {
    description = "Library to be able to send an email";
  };
}
