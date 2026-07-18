{
  lib,
  stdenv,
  fetchFromGitHub,
  fzf,
  installShellFiles,
  makeWrapper,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "git-smash";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "anthraxx";
    repo = "git-smash";
    tag = "v${finalAttrs.version}";
    hash = "sha256-M93lHa3BH0DqumnroNPGMs7V/FLiCjEjJE8V+G4puzQ=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  cargoHash = "sha256-Ux5kcr12LwPVXFdS7oeYQcvhaTyHBahxwXyo1aqOB5g=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd git-smash \
      --bash <($out/bin/git-smash completions bash) \
      --fish <($out/bin/git-smash completions fish) \
      --zsh <($out/bin/git-smash completions zsh)
  '';

  postFixup = ''
    wrapProgram "$out/bin/git-smash" --suffix PATH : "${lib.makeBinPath [ fzf ]}"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Smash staged changes into previous commits to support your Git workflow, pull request and feature branch maintenance";
    homepage = "https://github.com/anthraxx/git-smash";
    changelog = "https://github.com/anthraxx/git-smash/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcyran ];
    mainProgram = "git-smash";
  };
})
