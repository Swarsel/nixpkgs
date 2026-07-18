{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  bacon,
  buildPackages,
  installShellFiles,
  nix-update-script,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  withSound ? false,
}:

let
  soundDependencies =
    lib.optionals stdenv.hostPlatform.isLinux [
      alsa-lib
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      # bindgenHook is only included on darwin as it is needed to build `coreaudio-sys`, a darwin-specific crate
      rustPlatform.bindgenHook
    ];
in

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bacon";
  version = "3.24.0";

  src = fetchFromGitHub {
    owner = "Canop";
    repo = "bacon";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rfbK5MrCytBVISXVkazBDnZZxjZQ3ze348mlTyanTWM=";
  };

  nativeBuildInputs = [
    installShellFiles
  ]
  ++ lib.optionals withSound [
    pkg-config
  ];

  buildInputs = lib.optionals withSound soundDependencies;
  cargoHash = "sha256-s49qZMD922l6KKSFRhVIGp6+7E0S+q7McV9PT2F0RQc=";

  postInstall =
    let
      bacon = "${stdenv.hostPlatform.emulator buildPackages} $out/bin/bacon";
    in
    lib.optionalString (stdenv.hostPlatform.emulatorAvailable buildPackages) ''
      installShellCompletion --cmd bacon \
        --bash <(COMPLETE=bash ${bacon}) \
        --fish <(COMPLETE=fish ${bacon}) \
        --zsh <(COMPLETE=zsh ${bacon})
    '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  buildFeatures = lib.optionals withSound [
    "sound"
  ];

  passthru = {
    tests = {
      withSound = bacon.override { withSound = true; };
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Background rust code checker";
    homepage = "https://github.com/Canop/bacon";
    changelog = "https://github.com/Canop/bacon/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      FlorianFranzen
      matthiasbeyer
    ];

    mainProgram = "bacon";
  };
})
