{
  lib,
  stdenv,
  fetchFromGitHub,
  bun,
  cargo-tauri,
  glib,
  glib-networking,
  gst_all_1,
  makeWrapper,
  nodejs,
  openssl,
  pkg-config,
  rustPlatform,
  webkitgtk_4_1,
  wrapGAppsHook3,
  writableTmpDirAsHomeHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "iloader";
  version = "2.2.6";

  src = fetchFromGitHub {
    owner = "nab138";
    repo = "iloader";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-zSl08bhJ/OrdcvvL1ciybxgnLqrg4IinmcGXrsPQYyQ=";
  };

  patches = [ ./disable-update.patch ];

  postPatch = ''
    cp -r ${finalAttrs.nodeModules}/node_modules .
    chmod -R +w node_modules
    patchShebangs --build node_modules
  '';

  nativeBuildInputs = [
    bun
    cargo-tauri.hook
    nodejs
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ wrapGAppsHook3 ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ makeWrapper ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    webkitgtk_4_1
    glib
    glib-networking
    openssl
  ];

  cargoHash = "sha256-6nDqIikItl5SuHN2o/iQREiOkY+bYkP7akShOEtY9JY=";
  doCheck = false;

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/bin
    makeWrapper $out/Applications/iloader.app/Contents/MacOS/iloader $out/bin/iloader
  '';

  __structuredAttrs = true;
  buildAndTestSubdir = "src-tauri";
  cargoRoot = "src-tauri";

  nodeModules = stdenv.mkDerivation {
    inherit (finalAttrs) src version;
    pname = "${finalAttrs.pname}-node_modules";

    nativeBuildInputs = [
      bun
      writableTmpDirAsHomeHook
    ];

    buildPhase = ''
      runHook preBuild

      bun install \
        --cpu="*" \
        --frozen-lockfile \
        --ignore-scripts \
        --no-progress \
        --os="*"

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r node_modules $out/node_modules

      runHook postInstall
    '';

    dontConfigure = true;
    outputHash = "sha256-zB0BJrQuoIu7Y67WMfrVRsPPnJ6mhd5srL2M3zW6+1Q=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  tauriBuildFlags = [
    "--config"
    "ci.conf.json"
    "--no-sign"
  ];

  meta = {
    description = "User friendly sideloader";
    homepage = "https://github.com/nab138/iloader";
    changelog = "https://github.com/nab138/iloader/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ern775 ];

    platforms = [
      "aarch64-linux"
      "x86_64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "iloader";
  };
})
