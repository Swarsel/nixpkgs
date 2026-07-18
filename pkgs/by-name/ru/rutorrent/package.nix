{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rutorrent";
  version = "5.3.6";

  src = fetchFromGitHub {
    owner = "Novik";
    repo = "ruTorrent";
    tag = "v${finalAttrs.version}";
    hash = "sha256-73dJbmveZQg9ogrvlxevutx6eQDXWizdvi28bGJyiFQ=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r . "$out"
    runHook postInstall
  '';

  meta = {
    description = "Yet another web front-end for rTorrent";
    homepage = "https://github.com/Novik/ruTorrent";
    changelog = "https://github.com/Novik/ruTorrent/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
  };
})
