{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  menhir,
}:

buildDunePackage (finalAttrs: {
  pname = "odate";
  version = "0.7";

  src = fetchFromGitHub {
    owner = "hhugo";
    repo = "odate";
    rev = finalAttrs.version;
    sha256 = "sha256-C11HpftrYOCVyWT31wrqo8FVZuP7mRUkRv5IDeAZ+To=";
  };

  nativeBuildInputs = [ menhir ];
  minimalOCamlVersion = "4.07";

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Date and duration in OCaml";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
  };

})
