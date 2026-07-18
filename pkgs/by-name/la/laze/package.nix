{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  makeWrapper,
  ninja,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "laze";
  version = "0.1.39";

  src = fetchFromGitHub {
    owner = "kaspar030";
    repo = "laze";
    tag = finalAttrs.version;
    hash = "sha256-6jpsrRsBqowPL0TXke5gbgl6twuQLUsQ9yMGh4bJVds=";
  };

  nativeBuildInputs = [
    makeWrapper
    installShellFiles
    writableTmpDirAsHomeHook
  ];

  cargoHash = "sha256-kxbMkz3vEhXXzJ8yVDPAkCrALOq9+dNw9NoknCmGPIE=";

  postInstall = ''
    wrapProgram "$out/bin/laze" \
      --suffix PATH : ${lib.makeBinPath [ ninja ]}
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd laze \
      --bash <($out/bin/laze completion --generate bash) \
      --fish <($out/bin/laze completion --generate fish) \
      --zsh <($out/bin/laze completion --generate zsh)
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fast, declarative meta build system for C/C++/Rust projects, based on Ninja";
    homepage = "https://github.com/kaspar030/laze";
    changelog = "https://github.com/kaspar030/laze/blob/${finalAttrs.version}/CHANGELOG.md";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ dannixon ];
    mainProgram = "laze";
  };
})
