{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  git,
  installShellFiles,
  nix-update-script,
  rustPlatform,
}:
let
  emulatorAvailable = stdenv.hostPlatform.emulatorAvailable buildPackages;
  emulator = stdenv.hostPlatform.emulator buildPackages;
  version = "0.5.3";
in
rustPlatform.buildRustPackage {
  inherit version;
  pname = "git-prole";

  src = fetchFromGitHub {
    owner = "9999years";
    repo = "git-prole";
    tag = "v${version}";
    hash = "sha256-QwLkByC8gdAnt6geZS285ErdH8nfV3vsWjMF4hTzq9Y=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  cargoHash = "sha256-qghc8HtJfpTYXAwC2xjq8lLlCu419Ttnu/AYapkAulI=";

  nativeCheckInputs = [
    git
  ];

  postInstall = lib.optionalString emulatorAvailable ''
    manpages=$(mktemp -d)
    ${emulator} $out/bin/git-prole manpages "$manpages"
    for manpage in "$manpages"/*; do
      installManPage "$manpage"
    done

    installShellCompletion --cmd git-prole \
      --bash <(${emulator} $out/bin/git-prole completions bash) \
      --fish <(${emulator} $out/bin/git-prole completions fish) \
      --zsh <(${emulator} $out/bin/git-prole completions zsh)
  '';

  buildFeatures = [ "clap_mangen" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "`git-worktree(1)` manager";
    homepage = "https://github.com/9999years/git-prole";
    changelog = "https://github.com/9999years/git-prole/releases/tag/v${version}";
    license = [ lib.licenses.mit ];
    maintainers = [ lib.maintainers._9999years ];
    mainProgram = "git-prole";
  };
}
