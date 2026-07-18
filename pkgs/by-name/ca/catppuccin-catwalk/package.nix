{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  libwebp,
  pkg-config,
  rustPlatform,
}:
let
  version = "1.3.2";
in
rustPlatform.buildRustPackage {
  inherit version;
  pname = "catppuccin-catwalk";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "catwalk";
    tag = "v${version}";
    hash = "sha256-Yj9xTQJ0eu3Ymi2R9fgYwBJO0V+4bN4MOxXCJGQ8NjU=";
  };

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ];

  buildInputs = [ libwebp ];
  cargoHash = "sha256-stO8ejSC4UeEeMZZLIJ8Wabn7A6ZrWQlU5cZDSm2AVc=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd catwalk \
      --bash <("$out/bin/catwalk" completion bash) \
      --zsh <("$out/bin/catwalk" completion zsh) \
      --fish <("$out/bin/catwalk" completion fish)
  '';

  doInstallCheck = !stdenv.hostPlatform.isStatic && stdenv.hostPlatform.isElf;

  installCheckPhase = ''
    runHook preInstallCheck
    readelf -a $out/bin/catwalk | grep -F 'Shared library: [libwebp.so'
    runHook postInstallCheck
  '';

  meta = {
    description = "CLI for Catppuccin that takes in four showcase images and displays them all at once";
    homepage = "https://github.com/catppuccin/toolbox/tree/main/catwalk";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ryanccn ];
    mainProgram = "catwalk";
  };
}
