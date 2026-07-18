{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  cpu,
}:

buildDunePackage (finalAttrs: {
  pname = "parany";
  version = "14.0.1";

  src = fetchFromGitHub {
    owner = "UnixJunkie";
    repo = "parany";
    rev = "v${finalAttrs.version}";
    hash = "sha256-QR3Rq30iKhft+9tVCgJLOq9bwJe7bcay/kMTXjjCLjE=";
  };

  propagatedBuildInputs = [ cpu ];
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Generalized map/reduce for multicore computing";
    homepage = "https://github.com/UnixJunkie/parany";
    license = lib.licenses.lgpl2;
    maintainers = [ lib.maintainers.bcdarwin ];
  };
})
