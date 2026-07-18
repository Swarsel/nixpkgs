{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  dune-configurator,
  libtheora,
  ogg,
}:

buildDunePackage {
  inherit (ogg) version src;
  pname = "theora";
  buildInputs = [ dune-configurator ];

  propagatedBuildInputs = [
    ogg
    libtheora
  ];

  meta = {
    description = "Bindings to libtheora";
    homepage = "https://github.com/savonet/ocaml-theora";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ dandellion ];
  };
}
