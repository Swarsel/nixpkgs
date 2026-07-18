{
  lib,
  fetchFromGitHub,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "dtools";
  version = "0.4.6";

  src = fetchFromGitHub {
    owner = "savonet";
    repo = "ocaml-dtools";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-MIZM/IlPWPa/r/f8EXkhU8gZctOZeAIGZgxoGMF2IkE=";
  };

  minimalOCamlVersion = "4.05";

  meta = {
    description = "Library providing various helper functions to make daemons";
    homepage = "https://github.com/savonet/ocaml-dtools";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ dandellion ];
  };
})
