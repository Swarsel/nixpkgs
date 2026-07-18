{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  dune-configurator,
  lame,
  pkg-config,
}:

buildDunePackage (finalAttrs: {
  pname = "lame";
  version = "0.3.7";

  src = fetchFromGitHub {
    owner = "savonet";
    repo = "ocaml-lame";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-/ZzoGFQQrBf17TaBPSFDQ1yHaQnva56YLmscOacrKBI=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ lame ];
  minimalOCamlVersion = "4.06";

  meta = {
    description = "Bindings for the lame library which provides functions for encoding mp3 files";
    homepage = "https://github.com/savonet/ocaml-lame";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ dandellion ];
  };
})
