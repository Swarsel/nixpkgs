{
  lib,
  fetchFromGitHub,
  gitMinimal,
  gzip,
  makeBinaryWrapper,
  nix-update-script,
  openssl,
  pkg-config,
  python3,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fresh";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "sinelaw";
    repo = "fresh";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fVBDjcX0AjUTH+vKV5H4NYmknJYfHNHRizuzjQTHYpA=";
  };

  nativeBuildInputs = [
    gzip
    makeBinaryWrapper
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-bsIyf63U7/GNZnCD8g6RBykCiArwlD5v1YhrZNsf1is=";

  preBuild = ''
    mkdir -p $out/share/fresh-editor/plugins/
  '';

  nativeCheckInputs = [
    python3
    gitMinimal
    rustPlatform.bindgenHook
  ];

  # Due to issues with incorrect import paths with the actual app, I have disabled the checks below. Need to report upstream.
  checkFlags = [
    "--skip=e2e::"
    "--skip=services::plugins::embedded::tests::test_extract_plugins"
  ];

  postInstall = ''
    wrapProgram $out/bin/${finalAttrs.meta.mainProgram} \
      --add-flags "--no-upgrade-check" \
      --prefix PATH : ${lib.makeBinPath [ python3 ]}
    rm -rf $out/bin/fresh.dSYM
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  # Tests create a local http server to check update functionality
  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;

  cargoTestFlags = [
    "--lib"
    "--bins"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Terminal-based text editor with LSP support and TypeScript plugins";
    homepage = "https://github.com/sinelaw/fresh";
    changelog = "https://github.com/sinelaw/fresh/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Only;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
    ];

    maintainers = with lib.maintainers; [
      chillcicada
      dwt
      randoneering
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "fresh";
  };
})
