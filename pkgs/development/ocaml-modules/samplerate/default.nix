{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  dune-configurator,
  libsamplerate,
}:

buildDunePackage (finalAttrs: {
  pname = "samplerate";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "savonet";
    repo = "ocaml-samplerate";
    tag = "v${finalAttrs.version}";
    hash = "sha256-N3PSUSZ1tKNJcNPSgye6+8QQXcZIez72jk/YdNNOEUA=";
  };

  buildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ libsamplerate ];

  meta = {
    description = "Interface for libsamplerate";
    homepage = "https://github.com/savonet/ocaml-samplerate";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ dandellion ];
  };
})
