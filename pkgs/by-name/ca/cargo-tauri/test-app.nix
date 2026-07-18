{
  lib,
  stdenv,
  cargo-tauri,
  fetchPnpmDeps,
  glib-networking,
  libayatana-appindicator,
  nodejs,
  openssl,
  pkg-config,
  pnpmConfigHook,
  pnpm_10,
  rustPlatform,
  webkitgtk_4_1,
  wrapGAppsHook4,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (cargo-tauri) version src;
  inherit (cargo-tauri) cargoDeps;
  pname = "test-app";

  postPatch = lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace $cargoDepsCopy/*/libappindicator-sys-*/src/lib.rs \
      --replace "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"
  '';

  nativeBuildInputs = [
    cargo-tauri.hook

    nodejs
    pkg-config
    pnpmConfigHook
    pnpm_10
    rustPlatform.cargoCheckHook
    rustPlatform.cargoSetupHook
    wrapGAppsHook4
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    libayatana-appindicator
    webkitgtk_4_1
  ];

  # This example depends on the actual `api` package to be built in-tree
  preBuild = ''
    pnpm --filter '@tauri-apps/api' build
  '';

  postBuild = lib.optionalString stdenv.hostPlatform.isDarwin ''
    bundleDir="target/${stdenv.hostPlatform.rust.cargoShortTarget}/''${cargoBuildType:-release}/bundle/macos"
    touch "$bundleDir/.test-hidden-entry"
    touch "$bundleDir/test-visible-entry"
  '';

  doCheck = false;
  doInstallCheck = stdenv.hostPlatform.isDarwin;

  installCheckPhase = lib.optionalString stdenv.hostPlatform.isDarwin ''
    runHook preInstallCheck

    test -d "$out/Applications"

    shopt -s nullglob dotglob
    appBundles=("$out"/Applications/*.app)
    nonAppEntries=("$out"/Applications/*)
    shopt -u nullglob dotglob

    test "''${#appBundles[@]}" -gt 0

    for entry in "''${nonAppEntries[@]}"; do
      case "$entry" in
        *.app) ;;
        *)
          echo "unexpected non-.app entry in Applications: $entry" >&2
          exit 1
          ;;
      esac
    done

    runHook postInstallCheck
  '';

  buildAndTestSubdir = "examples/api/src-tauri";
  # No one should be actually running this, so lets save some time
  buildType = "debug";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      ;

    fetcherVersion = 4;
    hash = "sha256-m7haAF5ZIYG5NfsPwtzVF6Z83h/I4uT0YhNBk4ZXdpo=";
    pnpm = pnpm_10;
  };

  meta = {
    inherit (cargo-tauri.hook.meta) platforms;
  };
})
