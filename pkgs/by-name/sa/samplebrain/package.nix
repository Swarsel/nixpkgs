{
  lib,
  stdenv,
  fetchFromGitLab,
  fetchpatch,
  fftw,
  liblo,
  libsForQt5,
  libsndfile,
  makeDesktopItem,
  portaudio,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "samplebrain";
  version = "0.18.5";

  src = fetchFromGitLab {
    owner = "then-try-this";
    repo = "samplebrain";
    tag = "v${finalAttrs.version}_release";
    hash = "sha256-/pMHmwly5Dar7w/ZawvR3cWQHw385GQv/Wsl1E2w5p4=";
  };

  patches = [
    # Fixes build with recent liblo, see https://gitlab.com/then-try-this/samplebrain/-/merge_requests/16
    (fetchpatch {
      hash = "sha256-aaZJh/vx8fOqrJTuFzQ9+1mXvDQQXLy1k/2SwkMkVk4=";
      url = "https://gitlab.com/then-try-this/samplebrain/-/commit/032fd7c03931d1ca2d5c3d5e29901569aa2b2a86.patch";
    })
  ];

  nativeBuildInputs = with libsForQt5; [
    qmake
    wrapQtAppsHook
  ];

  buildInputs = [
    fftw
    liblo
    libsndfile
    portaudio
    libsForQt5.qtbase
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp samplebrain $out/bin
    install -m 444 -D desktop/samplebrain.svg $out/share/icons/hicolor/scalable/apps/samplebrain.svg
  '';

  desktopItem = makeDesktopItem {
    categories = [ "Audio" ];
    comment = "A sample masher designed by Aphex Twin";
    desktopName = "samplebrain";
    exec = "samplebrain";
    icon = "samplebrain";
    name = "samplebrain";
    type = "Application";
  };

  meta = {
    description = "Custom sample mashing app";
    homepage = "https://thentrythis.org/projects/samplebrain";
    changelog = "https://gitlab.com/then-try-this/samplebrain/-/releases/v${finalAttrs.version}_release";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ mitchmindtree ];
    platforms = lib.platforms.linux;
    mainProgram = "samplebrain";
  };
})
