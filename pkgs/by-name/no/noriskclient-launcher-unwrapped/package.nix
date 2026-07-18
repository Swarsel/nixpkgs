{
  lib,
  fetchFromGitHub,
  cargo-tauri,
  desktop-file-utils,
  fetchYarnDeps,
  glib,
  gtk3,
  libayatana-appindicator,
  nix-update-script,
  nodejs,
  openssl,
  pkg-config,
  rustPlatform,
  webkitgtk_4_1,
  yarnConfigHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "noriskclient-launcher-unwrapped";
  version = "0.6.24";

  src = fetchFromGitHub {
    owner = "NoRiskClient";
    repo = "noriskclient-launcher";
    tag = "v${finalAttrs.version}";
    hash = "sha256-X0j5cWAIMdpLSUSDAUx7oSJ42xvRLL1PY8JK9i4wGhA=";
  };

  patches = [
    # The tauri.conf.json is configured to build multiple apps. We don't want that here.
    ./disable-bundling.patch

    # Make the launcher find java from PATH, instead of downloading its own, which is not going to work on NixOS.
    ./java-from-path.patch
  ];

  postPatch = ''
    substituteInPlace $cargoDepsCopy/*/libappindicator-sys-*/src/lib.rs \
      --replace-fail "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"
  '';

  nativeBuildInputs = [
    cargo-tauri.hook
    desktop-file-utils
    nodejs
    pkg-config
    yarnConfigHook
  ];

  buildInputs = [
    glib
    gtk3
    libayatana-appindicator
    openssl
    webkitgtk_4_1
  ];

  cargoHash = "sha256-dwGJKLO+3i5FUgv+Huu1ZD/hFg/KdyWofApwkIDFD1I=";

  checkFlags = [
    # test fails to find correct function
    "--skip=utils::string_utils::safe_truncate"
  ];

  postInstall = ''
    desktop-file-edit \
    --set-name "NoRiskClient Launcher" \
    --set-comment "Launcher for NoRiskClient" \
    --set-key="Categories" --set-value="Game" \
    --set-key="Keywords" --set-value="nrc;minecraft;mc;" \
    $out/share/applications/NoRisk\ Launcher.desktop
  '';

  buildAndTestSubdir = finalAttrs.cargoRoot;
  cargoRoot = "src-tauri";

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-VWl6YqTiBRz85GICFKGwDZRBcITGQdWE7EUzW58wHdY=";
    yarnLock = "${finalAttrs.src}/yarn.lock";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Minecraft Launcher for NoRisk Client";

    longDescription = ''
      An easy way to launch the NoRisk Client, create modpacks,
      manage content for Minecraft, and much more - written in tauri.
    '';

    homepage = "https://norisk.gg";
    changelog = "https://github.com/NoRiskClient/noriskclient-launcher/blob/v3/changelogs/${finalAttrs.version}.txt";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ hythera ];
    platforms = lib.platforms.linux;
    mainProgram = "noriskclient-launcher-v3";
  };
})
