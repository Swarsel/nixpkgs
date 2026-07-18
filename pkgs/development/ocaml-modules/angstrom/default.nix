{
  lib,
  fetchFromGitHub,
  alcotest,
  bigstringaf,
  buildDunePackage,
  gitUpdater,
  ocaml,
  ocaml-syntax-shims,
  ppx_let,
}:

buildDunePackage (finalAttrs: {
  pname = "angstrom";
  version = "0.16.1";

  src = fetchFromGitHub {
    owner = "inhabitedtype";
    repo = "angstrom";
    rev = finalAttrs.version;
    hash = "sha256-EPqDK+7RU2vHEHvuoTXb8V2FkdXQ6tGu0ghbNPS3gZ4=";
  };

  buildInputs = [ ocaml-syntax-shims ];
  propagatedBuildInputs = [ bigstringaf ];
  doCheck = lib.versionAtLeast ocaml.version "4.08";

  checkInputs = [
    alcotest
    ppx_let
  ];

  minimalOCamlVersion = "4.04";
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "OCaml parser combinators built for speed and memory efficiency";
    homepage = "https://github.com/inhabitedtype/angstrom";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ sternenseemann ];
  };
})
