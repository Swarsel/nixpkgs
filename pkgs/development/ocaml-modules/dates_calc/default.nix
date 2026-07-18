{
  lib,
  fetchFromGitHub,
  alcotest,
  buildDunePackage,
  qcheck,
}:

buildDunePackage (finalAttrs: {
  pname = "dates_calc";
  version = "0.0.6";

  src = fetchFromGitHub {
    owner = "catalalang";
    repo = "dates-calc";
    rev = finalAttrs.version;
    sha256 = "sha256-B4li8vIK6AnPXJ1QSJ8rtr+JOcy4+h5sc1SH97U+Vgw=";
  };

  doCheck = true;

  checkInputs = [
    alcotest
    qcheck
  ];

  duneVersion = "3";
  minimalOCamlVersion = "4.11";

  meta = {
    description = "Date calculation library";
    homepage = "https://github.com/catalalang/dates-calc";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.niols ];
  };
})
