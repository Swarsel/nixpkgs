{
  lib,
  stdenv,
  fetchFromGitHub,
  libjack2,
  pkg-config,
  unstableGitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jack-link";
  version = "0.2.7";

  src = fetchFromGitHub {
    owner = "rncbc";
    repo = "jack_link";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FaFFKcTB70UDWtst7A2JeqzSgVGDkkaRhZS3II56ndU=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libjack2
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "jack_link bridges JACK transport with Ableton Link";
    homepage = "https://github.com/rncbc/jack_link";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ magnetophon ];
    platforms = lib.platforms.linux;
    mainProgram = "jack_link";
  };
})
