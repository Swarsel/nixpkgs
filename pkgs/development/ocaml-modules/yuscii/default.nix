{
  lib,
  alcotest,
  buildDunePackage,
  fetchzip,
  fmt,
  gcc,
  ocaml,
  uutf,
}:

buildDunePackage rec {
  pname = "yuscii";
  version = "0.3.0";

  src = fetchzip {
    url = "https://github.com/mirage/yuscii/releases/download/v${version}/yuscii-v${version}.tbz";
    sha256 = "0idywlkw0fbakrxv65swnr5bj7f2vns9kpay7q03gzlv82p670hy";
  };

  doCheck = lib.versionAtLeast ocaml.version "4.08";

  nativeCheckInputs = [
    gcc
  ];

  checkInputs = [
    alcotest
    fmt
    uutf
  ];

  duneVersion = "3";
  minimalOCamlVersion = "4.03";

  meta = {
    description = "Simple mapper between UTF-7 to Unicode according RFC2152";
    homepage = "https://github.com/mirage/yuscii";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
