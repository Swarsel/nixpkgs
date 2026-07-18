{
  lib,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hyperfine";
  version = "1.20.0";

  src = fetchFromGitHub {
    owner = "sharkdp";
    repo = "hyperfine";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ee889Fx2Mi2005SrlcKc7TwG8ZIpTqisfLebXYadvSg=";
  };

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-0e6QDVv//WQtfvrJj6jW1sEz7jFv3VC6UKLvclyytLs=";

  postInstall = ''
    installManPage doc/hyperfine.1

    installShellCompletion \
      $releaseDir/build/hyperfine-*/out/hyperfine.{bash,fish} \
      --zsh $releaseDir/build/hyperfine-*/out/_hyperfine
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command-line benchmarking tool";
    homepage = "https://github.com/sharkdp/hyperfine";
    changelog = "https://github.com/sharkdp/hyperfine/blob/v${finalAttrs.version}/CHANGELOG.md";

    license = with lib.licenses; [
      asl20 # or
      mit
    ];

    maintainers = with lib.maintainers; [
      mdaniels5757
      thoughtpolice
    ];

    mainProgram = "hyperfine";
  };
})
