{
  lib,
  stdenv,
  fetchFromGitHub,
  apple-sdk_14,
  cargo-tauri,
  darwin,
  deltachat-desktop,
  fetchPnpmDeps,
  gst_all_1,
  libayatana-appindicator,
  makeWrapper,
  nodejs,
  openssl,
  perl,
  pkg-config,
  pnpmConfigHook,
  pnpm_10,
  python3,
  rustPlatform,
  versionCheckHook,
  webkitgtk_4_1,
  wrapGAppsHook4,
}:

let
  pnpm = pnpm_10;
in
rustPlatform.buildRustPackage (finalAttrs: {
  inherit (deltachat-desktop)
    version
    src
    pnpmDeps
    ;

  pname = "deltachat-tauri";

  postPatch = lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace $cargoDepsCopy/*/libappindicator-sys-*/src/lib.rs \
      --replace-fail libayatana-appindicator3.so.1 '${libayatana-appindicator}/lib/libayatana-appindicator3.so.1'
  '';

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    perl
    pnpm
    pnpmConfigHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    pkg-config
    python3
    wrapGAppsHook4
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.autoSignDarwinBinariesHook
  ];

  buildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [
      gst_all_1.gst-libav
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad
      gst_all_1.gstreamer
      libayatana-appindicator
      openssl
      webkitgtk_4_1
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      apple-sdk_14
    ];

  cargoHash = "sha256-iGgsG5V0cFzoudVASGqLakpuy2h4oD979LHuBclj+3o=";

  env = {
    VERSION_INFO_GIT_REF = finalAttrs.src.tag;
  };

  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    install -Dm 444 images/tray/deltachat.svg "$out/share/icons/hicolor/scalable/apps/deltachat-tauri.svg"
  '';

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __structuredAttrs = true;
  buildAndTestSubdir = "packages/target-tauri";

  meta = {
    description = "Email-based instant messaging for Desktop";
    homepage = "https://github.com/deltachat/deltachat-desktop";
    changelog = "https://github.com/deltachat/deltachat-desktop/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.dotlambda ];
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
    mainProgram = "deltachat-tauri";
  };
})
