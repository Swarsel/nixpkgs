{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  installShellFiles,
  nix-update-script,
  rustPlatform,
}:
let
  canRunStripAnsi = stdenv.hostPlatform.emulatorAvailable buildPackages;
  stripAnsiCompletions = "${stdenv.hostPlatform.emulator buildPackages} $out/bin/strip-ansi-completions";
in
rustPlatform.buildRustPackage {
  pname = "strip-ansi";
  version = "0.1.0-unstable-2024-09-01";

  src = fetchFromGitHub {
    owner = "KSXGitHub";
    repo = "strip-ansi-cli";
    rev = "60dbdbc22b41f743c237cb75b11e72cf7884b792";
    hash = "sha256-FvozEjNWXE1XEIq/06JehES7LVKoWmzIoaB4fD1kUsY=";
  };

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-kebx9OrAeh4c01VDUmlfTVn0EgFfzewiXjaQ3qtJrPY=";

  postInstall = lib.optionalString canRunStripAnsi ''
    installShellCompletion --cmd strip-ansi \
      --bash <(${stripAnsiCompletions} bash) \
      --fish <(${stripAnsiCompletions} fish) \
      --zsh <(${stripAnsiCompletions} zsh)
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Strip ANSI escape sequences from text";
    homepage = "https://github.com/KSXGitHub/strip-ansi-cli";
    license = [ lib.licenses.mit ];
    maintainers = [ lib.maintainers._9999years ];
    mainProgram = "strip-ansi";
  };
}
