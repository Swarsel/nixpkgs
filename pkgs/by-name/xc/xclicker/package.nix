{
  lib,
  stdenv,
  fetchFromGitHub,
  gtk3,
  libxtst,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xclicker";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "robiot";
    repo = "xclicker";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zVbOfqh21+/41N3FcAFajcZCrQ8iNqedZjgNQO0Zj04=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    libxtst
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 ./src/xclicker $out/bin/xclicker
    install -Dm644 $src/assets/xclicker.desktop $out/share/applications/xclicker.desktop
    install -Dm644 $src/assets/icon.png $out/share/icons/hicolor/256x256/apps/xclicker.png
    runHook postInstall
  '';

  mesonBuildType = "release";

  meta = {
    description = "Fast gui autoclicker for x11 linux desktops";
    homepage = "https://xclicker.xyz/";
    changelog = "https://github.com/robiot/xclicker/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      gepbird
      tomasajt
    ];

    platforms = lib.platforms.linux;
    mainProgram = "xclicker";
  };
})
