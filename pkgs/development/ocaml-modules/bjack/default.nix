{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  dune-configurator,
  libjack2,
  libsamplerate,
}:

buildDunePackage (finalAttrs: {
  pname = "bjack";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "savonet";
    repo = "ocaml-bjack";
    rev = "v${finalAttrs.version}";
    hash = "sha256-jIxxqBVWphWYyLh+24rTxk4WWfPPdGCvNdevFJEKw70=";
  };

  buildInputs = [ dune-configurator ];

  propagatedBuildInputs = [
    libsamplerate
    libjack2
  ];

  meta = {
    description = "Blocking API for the jack audio connection kit";
    homepage = "https://github.com/savonet/ocaml-bjack";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ dandellion ];
  };
})
