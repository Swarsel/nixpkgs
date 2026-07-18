{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  dune-configurator,
  libopus,
  ogg,
  pkg-config,
}:

buildDunePackage {
  inherit (ogg) version src;
  pname = "opus";
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ dune-configurator ];

  propagatedBuildInputs = [
    ogg
    libopus.dev
  ];

  meta = {
    description = "Bindings to libopus";
    homepage = "https://github.com/savonet/ocaml-opus";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ dandellion ];
  };
}
