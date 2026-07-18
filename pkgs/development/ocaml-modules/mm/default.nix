{
  lib,
  fetchFromGitHub,
  alsa,
  ao,
  buildDunePackage,
  dune-configurator,
  mad,
  pulseaudio,
  theora,
}:

buildDunePackage (finalAttrs: {
  pname = "mm";
  version = "0.8.6";

  src = fetchFromGitHub {
    owner = "savonet";
    repo = "ocaml-mm";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-ME6Naza7OvZ/63zEjrPeKq5JwMoMfV2fpkCuZdtCZ/c=";
  };

  buildInputs = [ dune-configurator ];

  propagatedBuildInputs = [
    alsa
    ao
    mad
    pulseaudio
    theora
  ]; # ocamlsdl is blocked in nixpkgs from building for ocaml >= 4.06

  duneVersion = "3";
  minimalOCamlVersion = "4.12";

  meta = {
    description = "High-level library to create and manipulate multimedia streams";
    homepage = "https://github.com/savonet/ocaml-mm";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ dandellion ];
  };
})
