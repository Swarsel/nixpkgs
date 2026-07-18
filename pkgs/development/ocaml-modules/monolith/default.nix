{
  lib,
  fetchFromGitLab,
  afl-persistent,
  buildDunePackage,
  pprint,
  version ? "20250922",
}:

buildDunePackage {
  inherit version;
  pname = "monolith";

  src = fetchFromGitLab {
    owner = "fpottier";
    repo = "monolith";
    tag = version;
    hash = "sha256-uYUbrWSE99556jiCgDUc8xDaob3rFPXLBMPM3lN6Xh8=";
    domain = "gitlab.inria.fr";
  };

  propagatedBuildInputs = [
    afl-persistent
    pprint
  ];

  minimalOCamlVersion = "4.12";

  meta = {
    description = "Facilities for testing an OCaml library";
    homepage = "https://cambium.inria.fr/~fpottier/monolith/doc/monolith/Monolith/index.html";
    changelog = "https://gitlab.inria.fr/fpottier/monolith/-/raw/${version}/CHANGES.md";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ lib.maintainers.vbgl ];
  };
}
