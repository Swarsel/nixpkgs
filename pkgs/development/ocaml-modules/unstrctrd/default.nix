{
  lib,
  alcotest,
  angstrom,
  bigstringaf,
  buildDunePackage,
  crowbar,
  fetchzip,
  fmt,
  hxd,
  ke,
  rresult,
  uutf,
}:

buildDunePackage rec {
  pname = "unstrctrd";
  version = "0.4";

  src = fetchzip {
    url = "https://github.com/dinosaure/unstrctrd/releases/download/v${version}/unstrctrd-${version}.tbz";
    hash = "sha256-CGcDqEr+VDTbDYkjxeYB6IFWiTkOTLJJl/Y2bHtv19g=";
  };

  propagatedBuildInputs = [
    angstrom
    uutf
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    bigstringaf
    crowbar
    fmt
    hxd
    ke
    rresult
  ];

  meta = {
    description = "Library for parsing email headers";
    homepage = "https://github.com/dinosaure/unstrctrd";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
