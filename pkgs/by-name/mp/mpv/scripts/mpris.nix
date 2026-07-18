{
  lib,
  stdenv,
  fetchFromGitHub,
  ffmpeg,
  gitUpdater,
  glib,
  mpv-unwrapped,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mpv-mpris";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "hoyon";
    repo = "mpv-mpris";
    rev = finalAttrs.version;
    hash = "sha256-Q2kNaXZtI6U+x2f00x5CiHZq4o64xFTNC/3W4IiP0+4=";
  };

  postPatch = ''
    substituteInPlace Makefile --replace-fail 'PKG_CONFIG =' 'PKG_CONFIG ?='
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    glib
    mpv-unwrapped
    ffmpeg
  ];

  installFlags = [ "SCRIPTS_DIR=${placeholder "out"}/share/mpv/scripts" ];
  # Otherwise, the shared object isn't `strip`ped. See:
  # https://discourse.nixos.org/t/debug-why-a-derivation-has-a-reference-to-gcc/7009
  stripDebugList = [ "share/mpv/scripts" ];
  passthru.scriptName = "mpris.so";
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "MPRIS plugin for mpv";
    homepage = "https://github.com/hoyon/mpv-mpris";
    changelog = "https://github.com/hoyon/mpv-mpris/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ajs124 ];
    platforms = lib.platforms.linux;
  };
})
