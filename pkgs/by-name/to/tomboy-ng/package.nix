{
  lib,
  stdenv,
  fetchFromGitHub,
  at-spi2-atk,
  autoPatchelfHook,
  cairo,
  fpc,
  gdk-pixbuf,
  glib,
  gtk2,
  lazarus,
  libnotify,
  libx11,
  nix-update-script,
  pango,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "tomboy-ng";
  version = "0.42";

  src = fetchFromGitHub {
    owner = "tomboy-notes";
    repo = "tomboy-ng";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ppvEZeVHJ4DHIdEXfLOWcb4Wbsi6YVKqm6NGQ7lPtdg=";
  };

  patches = [ ./simplify-build-script.patch ];
  postPatch = "ln -s ${finalAttrs.kcontrols} kcontrols";

  nativeBuildInputs = [
    fpc
    lazarus
    autoPatchelfHook
  ];

  buildInputs = [
    glib
    cairo
    pango
    gtk2
    gdk-pixbuf
    at-spi2-atk
    libx11
    libnotify
  ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  env = {
    COMPILER = lib.getExe' fpc "fpc";
    LAZ_DIR = "${lazarus}/share/lazarus";
  };

  kcontrols = fetchFromGitHub {
    hash = "sha256-AHpcbt5v9Y/YG9MZ/zCLLH1Pfryv0zH8UFCgY/RqrdQ=";
    name = "kcontrols";
    owner = "davidbannon";
    repo = "KControls";
    rev = "4b74f50599544aa05d76385c21795ca9026e9657";
  };

  passthru.updateScript = nix-update-script {
    # Stable releases only
    extraArgs = [
      "--version-regex"
      "^v([0-9.]+)$"
    ];
  };

  meta = {
    description = "Note taking app that works and synchronises between Linux, Windows and macOS";
    homepage = "https://github.com/tomboy-notes/tomboy-ng";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ pluiedev ];
    platforms = lib.platforms.unix ++ lib.platforms.windows;
    mainProgram = "tomboy-ng";
  };
})
