{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  dune-configurator,
  flac,
  ogg,
  pkg-config,
}:

buildDunePackage {
  inherit (ogg) version src;
  pname = "flac";
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ dune-configurator ];

  propagatedBuildInputs = [
    ogg
    flac.dev
  ];

  meta = {
    description = "Bindings for flac";
    homepage = "https://github.com/savonet/ocaml-flac";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ dandellion ];
  };
}
