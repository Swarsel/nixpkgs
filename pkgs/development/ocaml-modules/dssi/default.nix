{
  lib,
  fetchFromGitHub,
  alsa-lib,
  buildDunePackage,
  dune-configurator,
  ladspa,
}:

buildDunePackage (finalAttrs: {
  pname = "dssi";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "savonet";
    repo = "ocaml-dssi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pkeiAawAraPPk1X71DZ1s5rsMeShz2UyMJfbr0KvK7s=";
  };

  buildInputs = [ dune-configurator ];

  propagatedBuildInputs = [
    ladspa
    alsa-lib
  ];

  meta = {
    description = "Bindings for the DSSI API which provides audio synthesizers";
    homepage = "https://github.com/savonet/ocaml-dssi";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ dandellion ];
  };
})
