{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  dune-configurator,
  libvorbis,
  ogg,
}:

buildDunePackage {
  inherit (ogg) version src;
  pname = "vorbis";
  buildInputs = [ dune-configurator ];

  propagatedBuildInputs = [
    ogg
    libvorbis
  ];

  meta = {
    description = "Bindings to libvorbis";
    homepage = "https://github.com/savonet/ocaml-vorbis";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ dandellion ];
  };
}
