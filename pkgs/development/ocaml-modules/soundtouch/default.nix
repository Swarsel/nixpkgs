{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  dune-configurator,
  soundtouch,
}:

buildDunePackage rec {
  pname = "soundtouch";
  version = "0.1.9";

  src = fetchFromGitHub {
    owner = "savonet";
    repo = "ocaml-soundtouch";
    rev = "v${version}";
    sha256 = "sha256-81Mhk4PZx4jGrVIevzMslvVbKzipzDzHWnbtOjeZCI8=";
  };

  buildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ soundtouch ];

  meta = {
    description = "Bindings for the soundtouch library which provides functions for changing pitch and timestretching audio data";
    homepage = "https://github.com/savonet/ocaml-soundtouch";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ dandellion ];
  };
}
