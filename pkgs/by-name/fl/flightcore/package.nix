{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  cargo-tauri,
  copyDesktopItems,
  fetchNpmDeps,
  glib-networking,
  makeDesktopItem,
  nodejs,
  openssl,
  pkg-config,
  rustPlatform,
  webkitgtk_4_1,
  wrapGAppsHook4,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "flightcore";
  version = "3.2.2";

  src = fetchFromGitHub {
    owner = "R2NorthstarTools";
    repo = "FlightCore";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eTRtd616hWHgj3wg+jtrt/tFkaxUeKSN0d+XO1CghsE=";
  };

  nativeBuildInputs = [
    cargo-tauri.hook
    copyDesktopItems
    nodejs
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wrapGAppsHook4
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    openssl
    webkitgtk_4_1
  ];

  cargoHash = "sha256-weidVeEIo3IIV+Xwe1htV46fRymOo5aRzHAEKQwKbvU=";

  # Copy [frontend] to where it can be picked up by Tauri.
  preBuild = ''
    ln -s "${finalAttrs.frontend}"/dist src-vue
  '';

  __structuredAttrs = true;
  buildAndTestSubdir = finalAttrs.cargoRoot;
  cargoRoot = "src-tauri";

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Game"
        "PackageManager"
      ];

      comment = finalAttrs.meta.description;
      desktopName = "FlightCore";
      exec = "flightcore";
      icon = "flightcore";
      name = "FlightCore";
      terminal = false;
    })
  ];

  frontend = buildNpmPackage {
    inherit (finalAttrs) version src;
    pname = "${finalAttrs.pname}-frontend";
    # Hash of dependencies fetched from upstream's `src-vue/package-lock.json`
    # file.
    npmDepsHash = "sha256-2PiMB9X/tp1QtTfUgVnH6caE+m2QSKTMYxPUHAUPWhQ=";

    installPhase = ''
      runHook preInstall

      mkdir -p "$out"
      cp -a dist "$out"

      runHook postInstall
    '';

    sourceRoot = "source/src-vue";
  };

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) pname version src;
    # Hash of dependencies fetched from upstream's `package-lock.json` file.
    hash = "sha256-+xrNKFcCatqbl79j/tSLFNTYjxXANFb3/vgWXYY2PGo=";
  };

  # This override does the following:
  #
  # * Disables creating updater artifacts - the default behavior causes issues
  #   with building the package, but since it is going to be distributed via a
  #   software repository, it won't need to auto-update itself anyways.
  #
  # * Empties `beforeBuildCommand` - the upstream Tauri configuration includes
  #   commands that automatically build the software's front-end, before
  #   building its back-end. However, since Nixpkgs requires NPM dependencies
  #   to be hashed, we need to build the front-end in a separate step.
  #
  #   This way, we end up fetching the NPM dependencies from both
  #   `source/package.json`, and `source/src-vue/package.json`.
  tauriBuildFlags = "-c ${./override-tauri.conf.json}";

  meta = {
    description = "Updater and mod manager for Northstar";
    homepage = "https://github.com/R2NorthstarTools/FlightCore";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ username-generic ];
    platforms = lib.platforms.all;
    mainProgram = "flightcore";
  };
})
