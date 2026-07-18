{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  dune-configurator,
  portaudio,
}:

buildDunePackage (finalAttrs: {
  pname = "portaudio";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "savonet";
    repo = "ocaml-portaudio";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-rMSE+ta7ughjjCnz4oho1D3VGaAsUlLtxizvxZT0/cQ=";
  };

  buildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ portaudio ];

  meta = {
    description = "Bindings for the portaudio library which provides high-level functions for using soundcards";
    homepage = "https://github.com/savonet/ocaml-portaudio";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ dandellion ];
  };
})
