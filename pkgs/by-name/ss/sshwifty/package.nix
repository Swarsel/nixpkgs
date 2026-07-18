{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchNpmDeps,
  nix-update-script,
  nixosTests,
  nodejs,
  npmHooks,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "sshwifty";
  version = "0.4.7-beta-release";

  src = fetchFromGitHub {
    owner = "nirui";
    repo = "sshwifty";
    tag = finalAttrs.version;
    hash = "sha256-Da/sgfhmSkUim05mJDNgxMohiLtAFdt3jyzsT/4vjj0=";
  };

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  vendorHash = "sha256-lJv1mBwwd9CTbSFVdu7H3Y9jkAJStMEa2SRYKAGOQUI=";

  preBuild = ''
    # Generate static pages
    npm run generate
  '';

  postInstall = ''
    find $out/bin ! -name sshwifty -type f -exec rm -rf {} \;
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-X github.com/nirui/sshwifty/application.version=${finalAttrs.version}"
  ];

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-6E7QAJO4R9Iszc8olyPnLUUAmrvMLDFivV3QN11qa60=";
  };

  overrideModAttrs = oldAttrs: {
    nativeBuildInputs = lib.filter (drv: drv != npmHooks.npmConfigHook) oldAttrs.nativeBuildInputs;
    preBuild = null;
  };

  passthru = {
    tests = { inherit (nixosTests) sshwifty; };

    updateScript = nix-update-script {
      extraArgs = [
        "--version=unstable"
        "--version-regex=^([0-9.]+(?!.+-prebuild).+$)"
      ];
    };
  };

  meta = {
    description = "WebSSH & WebTelnet client";
    homepage = "https://github.com/nirui/sshwifty";
    changelog = "https://github.com/nirui/sshwifty/releases/tag/${finalAttrs.version}";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ ungeskriptet ];
    mainProgram = "sshwifty";
  };
})
