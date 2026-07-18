{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  camlp-streams,
  num,
  ounit,
  qcheck,
  qtest,
  doCheck ? true,
}:

buildDunePackage (finalAttrs: {
  inherit doCheck;
  pname = "batteries";
  version = "3.11.0";

  src = fetchFromGitHub {
    owner = "ocaml-batteries-team";
    repo = "batteries-included";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RFozhk/kGgBg/2WnTYCNwi+kZwJ+l5o7z0YVons5yyw=";
  };

  propagatedBuildInputs = [
    camlp-streams
    num
  ];

  nativeCheckInputs = [ qtest ];

  checkInputs = [
    ounit
    qcheck
  ];

  checkTarget = "test";

  meta = {
    description = "OCaml Batteries Included";

    longDescription = ''
      A community-driven effort to standardize on an consistent, documented,
      and comprehensive development platform for the OCaml programming
      language.
    '';

    homepage = "https://ocaml-batteries-team.github.io/batteries-included/hdoc2/";
    license = lib.licenses.lgpl21Plus;
  };
})
