{
  lib,
  fetchFromGitHub,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "octavius";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "ocaml-doc";
    repo = "octavius";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-/S6WpIo1c5J9uM3xgtAM/elhnsl0XimnIFsKy3ootbA=";
  };

  doCheck = true;
  minimalOCamlVersion = "4.03";

  meta = {
    description = "Ocamldoc comment syntax parser";
    homepage = "https://github.com/ocaml-doc/octavius";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ vbgl ];
  };
})
