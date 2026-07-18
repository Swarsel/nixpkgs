{
  lib,
  fetchFromGitLab,
  alcotest,
  buildDunePackage,
  qcheck,
  qcheck-alcotest,
}:

buildDunePackage (finalAttrs: {
  pname = "pratter";
  version = "5.0.1";

  src = fetchFromGitLab {
    owner = "koizel";
    repo = "pratter";
    tag = finalAttrs.version;
    hash = "sha256-Ib7EplEvOuYcAS9cfzo5994SqCv2eiysLekYfH09IMw=";
    domain = "forge.tedomum.net";
  };

  doCheck = true;

  checkInputs = [
    alcotest
    qcheck
    qcheck-alcotest
  ];

  minimalOCamlVersion = "4.10";

  meta = {
    description = "Extended Pratt parser";
    homepage = "https://github.com/gabrielhdt/pratter";
    changelog = "https://github.com/gabrielhdt/pratter/raw/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
})
