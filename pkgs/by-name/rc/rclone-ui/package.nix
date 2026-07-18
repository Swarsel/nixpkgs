{
  lib,
  fetchFromGitHub,
  cargo-tauri,
  fetchNpmDeps,
  glib-networking,
  libappindicator,
  nix-update-script,
  nodejs,
  npmHooks,
  openssl,
  pkg-config,
  rustPlatform,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rclone-ui";
  version = "3.5.4";

  src = fetchFromGitHub {
    owner = "rclone-ui";
    repo = "rclone-ui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VnMNKBtZu5mdsvW7ljl+RNNj44bK+s5QrdGFaYvS2o0=";
  };

  # Disable tauri bundle updater, can be removed when #389107 is merged
  patches = [ ./remove_updater.patch ];

  postPatch = ''
    substituteInPlace src-tauri/tauri.conf.json \
      --replace-fail '"mainBinaryName": "Rclone UI"' '"mainBinaryName": "${finalAttrs.meta.mainProgram}"'
    substituteInPlace src-tauri/Cargo.toml \
       --replace-fail 'name = "app"' 'name = "${finalAttrs.pname}"'
  '';

  nativeBuildInputs = [
    npmHooks.npmConfigHook
    nodejs

    cargo-tauri.hook

    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    openssl
    webkitgtk_4_1
    glib-networking
    libappindicator
  ];

  cargoHash = "sha256-r4orImEIUC+wQgnvkiO8/apXSgQ18LxJFoWgweYGgks=";

  postInstall = ''
    wrapProgram $out/bin/rclone-ui \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libappindicator ]}
  '';

  buildAndTestSubdir = finalAttrs.cargoRoot;
  cargoRoot = "src-tauri";
  dontWrapGApps = true;

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    forceGitDeps = true;
    hash = "sha256-cBPJgaPHjgn+SByZFZ/SCOZG/YY4OQWUUlX844YHyUU=";
    name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cross-platform desktop GUI for rclone & S3";
    homepage = "https://github.com/rclone-ui/rclone-ui";
    changelog = "https://github.com/rclone-ui/rclone-ui/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ genga898 ];
    mainProgram = "rclone-ui";
    downloadPage = "https://github.com/rclone-ui/rclone-ui";
  };
})
