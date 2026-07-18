{
  lib,
  fetchFromGitHub,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "dolog";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "UnixJunkie";
    repo = "dolog";
    rev = "v${finalAttrs.version}";
    hash = "sha256-g68260mcb4G4wX8y4T0MTaXsYnM9wn2d0V1VCdSFZjY=";
  };

  meta = {
    description = "Minimalistic lazy logger in OCaml";
    homepage = "https://github.com/UnixJunkie/dolog";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ vbgl ];
  };
})
