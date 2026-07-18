{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  dune-configurator,
  libogg,
}:

buildDunePackage (finalAttrs: {
  pname = "ogg";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "savonet";
    repo = "ocaml-xiph";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mVMuPPjQRfwtQqpoUaEtTilMcGO0MJ4xiOd0D7ucOEQ=";
  };

  buildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ libogg ];
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Bindings to libogg";
    homepage = "https://github.com/savonet/ocaml-ogg";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ dandellion ];
  };
})
