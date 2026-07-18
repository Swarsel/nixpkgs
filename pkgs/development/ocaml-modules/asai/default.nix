{
  lib,
  fetchFromGitHub,
  algaeff,
  buildDunePackage,
  bwd,
}:

buildDunePackage (finalAttrs: {
  pname = "asai";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "RedPRL";
    repo = "asai";
    rev = finalAttrs.version;
    hash = "sha256-IpRLX7umpmlNt2uV2MB+YvjAvNk0+gl5plbBExVvcdM=";
  };

  propagatedBuildInputs = [
    algaeff
    bwd
  ];

  minimalOCamlVersion = "5.2";

  meta = {
    description = "Library for constructing and printing compiler diagnostics";
    homepage = "https://redprl.org/asai/asai/";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
