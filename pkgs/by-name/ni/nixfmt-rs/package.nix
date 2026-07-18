{
  lib,
  fetchFromGitHub,
  gitMinimal,
  installShellFiles,
  nix-update-script,
  nixfmt,
  rustPlatform,
  scdoc,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nixfmt-rs";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "nixfmt-rs";
    tag = finalAttrs.version;
    hash = "sha256-MsSefbTC6u9GAEB9PhDSz9GvWTCASgTxysIHRrqGINc=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
    scdoc
  ];

  cargoHash = "sha256-QSckmh8hBpQjpg0/4rwlpJZ2uxEZ1sPQvZfjmi4NFEc=";

  postBuild = ''
    scdoc < docs/nixfmt.1.scd > nixfmt.1
  '';

  nativeCheckInputs = [
    gitMinimal
  ];

  postInstall = ''
    installManPage nixfmt.1
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Rust reimplementation of nixfmt that produces byte-identical output to the Haskell original";
    homepage = "https://github.com/Mic92/nixfmt-rs";
    changelog = "https://github.com/Mic92/nixfmt-rs/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mpl20;

    maintainers = with lib.maintainers; [
      drupol
      mic92
    ];

    mainProgram = "nixfmt";
  };
})
