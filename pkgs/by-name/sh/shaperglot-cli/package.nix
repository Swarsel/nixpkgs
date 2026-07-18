{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "shaperglot-cli";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "googlefonts";
    repo = "shaperglot";
    tag = "v${finalAttrs.version}";
    hash = "sha256-g8f8Q2DvYNvm8i6S+9K/jhhUiuGw366dht0Khx3/INg=";
  };

  cargoHash = "sha256-ivl3Zq0HRn4yP9JKfbjSaaERjbQ3SAEWhHk6toFp8dE=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  installCheckPhase = ''
    runHook preInstallCheck

    describe_output="$("$out/bin/shaperglot" describe English)"
    [[ "$describe_output" == *'support'* ]]

    runHook postInstallCheck
  '';

  cargoBuildFlags = [
    "--package=shaperglot-cli"
  ];

  cargoTestFlags = [
    "--package=shaperglot-cli"
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Test font files for language support";
    homepage = "https://github.com/googlefonts/shaperglot";
    # The CHANGELOG.md file exists in this repository but is not actually used.
    changelog = "https://github.com/googlefonts/shaperglot/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      kachick
    ];

    mainProgram = "shaperglot";
  };
})
