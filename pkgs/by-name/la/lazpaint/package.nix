{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  fpc,
  lazarus-qt5,
  libsForQt5,
  libx11,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lazpaint";
  version = "7.3";

  src = fetchFromGitHub {
    owner = "bgrabitmap";
    repo = "lazpaint";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yT1HyvJcYEJgMkQxzCSD8s7/ttemxZaur9T+As8WdIo=";
  };

  nativeBuildInputs = [
    lazarus-qt5
    fpc
    libsForQt5.wrapQtAppsHook
    autoPatchelfHook
  ];

  buildInputs = with libsForQt5; [
    qtbase
    libqtpas
  ];

  preConfigure = ''
    patchShebangs --build configure
  '';

  buildPhase = ''
    runHook preBuild

    export HOME=$(mktemp -d)
    cp -r --no-preserve=mode ${finalAttrs.bgrabitmap} bgrabitmap
    cp -r --no-preserve=mode ${finalAttrs.bgracontrols} bgracontrols

    lazbuild --lazarusdir=${lazarus-qt5}/share/lazarus \
      --build-mode=ReleaseQt5 \
      bgrabitmap/bgrabitmap/bgrabitmappack.lpk \
      bgracontrols/bgracontrols.lpk \
      lazpaintcontrols/lazpaintcontrols.lpk \
      lazpaint/lazpaint.lpi

    runHook postBuild
  '';

  # Python is needed for scripts
  preFixup = ''
    qtWrapperArgs+=(--prefix PATH : ${lib.makeBinPath [ python3 ]})
  '';

  bgrabitmap = fetchFromGitHub {
    hash = "sha256-bA8tvo7Srm5kIZTVWEA2+gjqHab7LByyL/zqdQxeFlA=";
    owner = "bgrabitmap";
    repo = "bgrabitmap";
    tag = "v11.6.6";
  };

  bgracontrols = fetchFromGitHub {
    hash = "sha256-HqX9n4VpOyMwTz3fTweTTqzW+jA2BU62mm/X7Iwjd/8=";
    owner = "bgrabitmap";
    repo = "bgracontrols";
    tag = "v9.0.2";
  };

  runtimeDependencies = [
    libx11
  ];

  meta = {
    description = "Image editor like PaintBrush or Paint.Net";
    homepage = "https://lazpaint.github.io";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.linux;
    mainProgram = "lazpaint";
    downloadPage = "https://github.com/bgrabitmap/lazpaint/";
  };
})
