{
  lib,
  fetchFromGitHub,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "metadata";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "savonet";
    repo = "ocaml-metadata";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-g76R1ziRv3VDl0IEJOm626m/ywDz+qgHtQg0uPb0MCU=";
  };

  minimalOCamlVersion = "4.14";

  meta = {
    description = "Library to read metadata from files in various formats";
    homepage = "https://github.com/savonet/ocaml-metadata";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ dandellion ];
  };
})
