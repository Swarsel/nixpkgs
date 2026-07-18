{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gitUpdater,
  pkg-config,
  soundtouch,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "avisynthplus";
  version = "3.7.5";

  src = fetchFromGitHub {
    owner = "AviSynth";
    repo = "AviSynthPlus";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RkEZWsAKZABtl+SbRLCjMqyQoi9ainbaI9hWlpO6Fwo=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    soundtouch
  ];

  patchPhase = ''
    substituteInPlace ./avs_core/avisynth_conf.h.in \
        --replace-fail '@CORE_PLUGIN_INSTALL_PATH@' '/run/current-system/sw/lib'
  '';

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
    updateScript = gitUpdater { rev-prefix = "v"; };
  };

  meta = {
    description = "Improved version of the AviSynth frameserver";
    homepage = "https://avs-plus.net/";
    changelog = "https://github.com/AviSynth/AviSynthPlus/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ jopejoe1 ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "avisynth" ];
  };
})
