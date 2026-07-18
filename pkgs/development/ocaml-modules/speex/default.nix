{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  dune-configurator,
  ogg,
  speex,
}:

buildDunePackage {
  inherit (ogg) version src;
  pname = "speex";
  buildInputs = [ dune-configurator ];

  propagatedBuildInputs = [
    ogg
    speex.dev
  ];

  meta = {
    description = "Bindings to libspeex";
    homepage = "https://github.com/savonet/ocaml-speex";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ dandellion ];
  };
}
