{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  cmdliner,
  menhir,
}:
buildDunePackage (finalAttrs: {
  pname = "odds";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "raphael-proust";
    repo = "odds";
    tag = finalAttrs.version;
    hash = "sha256-tPDowkpsJQKCoeuXOb9zPORoudUvkRBZ3OzkH2QE2zg=";
  };

  nativeBuildInputs = [
    menhir
  ];

  buildInputs = [
    cmdliner
  ];

  minimalOCamlVersion = "5.0.0";

  meta = {
    description = "Dice roller";
    homepage = "https://github.com/raphael-proust/odds";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.Denommus ];
  };
})
