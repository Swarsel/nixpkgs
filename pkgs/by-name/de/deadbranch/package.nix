{
  lib,
  fetchFromGitHub,
  # nativeCheckInputs
  gitMinimal,
  # nativeBuildInputs
  installShellFiles,
  rustPlatform,
  # nativeInstallCheckInputs
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "deadbranch";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "armgabrielyan";
    repo = "deadbranch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ub06sn3CUlbU9LkDCbZJmoZ7CQef97HeXhRdW6ESw1U=";
  };

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-9AhTTvSv0HGQxglifmcEU0ApZuCIng7gFgfCMQLXpLo=";

  nativeCheckInputs = [
    gitMinimal
    writableTmpDirAsHomeHook
  ];

  postInstall = ''
    installManPage $releaseDir/build/deadbranch-*/out/deadbranch.1
    installShellCompletion --cmd deadbranch \
      --bash <($out/bin/deadbranch completions bash) \
      --fish <($out/bin/deadbranch completions fish) \
      --zsh <($out/bin/deadbranch completions zsh)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "Clean up stale git branches safely";
    homepage = "https://github.com/armgabrielyan/deadbranch";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mahyarmirrashed ];
    mainProgram = "deadbranch";
  };
})
