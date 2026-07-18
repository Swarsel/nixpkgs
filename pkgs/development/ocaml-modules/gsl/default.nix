{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  dune-configurator,
  gsl,
  pkg-config,
}:

buildDunePackage (finalAttrs: {
  pname = "gsl";
  version = "1.25.1";

  src = fetchFromGitHub {
    owner = "mmottl";
    repo = "gsl-ocaml";
    rev = finalAttrs.version;
    hash = "sha256-h1jO2RheBBzxiBgig2yEPk4YyBaZxStt5f+KNZqHdBo=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    dune-configurator
    gsl
  ];

  minimalOCamlVersion = "4.12";

  meta = {
    description = "OCaml bindings to the GNU Scientific Library";
    homepage = "https://mmottl.github.io/gsl-ocaml/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ vbgl ];
  };
})
