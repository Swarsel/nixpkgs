{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  dune-configurator,
  pkg-config,
  pulseaudio,
}:

buildDunePackage (finalAttrs: {
  pname = "pulseaudio";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "savonet";
    repo = "ocaml-pulseaudio";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-eG2HS5g3ycDftRDyXGBwPJE7VRnLXNUgcEgNfVm//ds=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ pulseaudio ];

  meta = {
    description = "Bindings to Pulseaudio client library";
    homepage = "https://github.com/savonet/ocaml-pulseaudio";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ dandellion ];
  };
})
