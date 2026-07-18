{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  rustPlatform,
}:
let
  version = "0.15.2";
in
rustPlatform.buildRustPackage {
  inherit version;
  pname = "pace";

  src = fetchFromGitHub {
    owner = "pace-rs";
    repo = "pace";
    tag = "pace-rs-v${version}";
    hash = "sha256-gyyf4GGHIEdiAWvzKbaOApFikoh3RLWBCZUfJ0MjbIE=";
  };

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-BuAVwILZCU6+/IBesyK4ZiefNmju49aFPyTcUUT1se8=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd pace \
      --bash <($out/bin/pace setup completions bash) \
      --fish <($out/bin/pace setup completions fish) \
      --zsh <($out/bin/pace setup completions zsh)
  '';

  meta = {
    description = "Command-line program for mindful time tracking";
    homepage = "https://github.com/pace-rs/pace";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ isabelroses ];
    mainProgram = "pace";
  };
}
