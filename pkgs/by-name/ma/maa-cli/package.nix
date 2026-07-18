{
  lib,
  stdenv,
  fetchFromGitHub,
  android-tools,
  git,
  installShellFiles,
  maa-assistant-arknights,
  makeWrapper,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "maa-cli";
  version = "0.5.9";

  src = fetchFromGitHub {
    owner = "MaaAssistantArknights";
    repo = "maa-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-TLm8B1cQ00l9aRADYU3Qv7nA04kDaxsXX86qvsTRWwk=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
    pkg-config
  ];

  buildInputs = [ openssl ];
  cargoHash = "sha256-pJlTcxF6nzV4HfMTs/gAzSUubDy2UlhzEIVeSWs6uX0=";

  # maa-cli would only search libMaaCore.so and resources in itself's path
  # https://github.com/MaaAssistantArknights/maa-cli/issues/67
  postInstall = ''
    mkdir -p $out/share/maa-assistant-arknights/
    ln -s ${maa-assistant-arknights}/share/maa-assistant-arknights/* $out/share/maa-assistant-arknights/
    ln -s ${maa-assistant-arknights}/lib/* $out/share/maa-assistant-arknights/
    mv $out/bin/maa $out/share/maa-assistant-arknights/

    makeWrapper $out/share/maa-assistant-arknights/maa $out/bin/maa \
      --prefix PATH : "${
        lib.makeBinPath [
          android-tools
          git
        ]
      }"

  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd maa \
      --bash <($out/bin/maa complete bash) \
      --fish <($out/bin/maa complete fish) \
      --zsh <($out/bin/maa complete zsh)

    mkdir -p manpage
    $out/bin/maa mangen --path manpage
    installManPage manpage/*
  '';

  buildFeatures = [ "git2" ];
  # https://github.com/MaaAssistantArknights/maa-cli/pull/126
  buildNoDefaultFeatures = true;

  meta = {
    description = "Simple CLI for MAA by Rust";
    homepage = "https://github.com/MaaAssistantArknights/maa-cli";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ Cryolitia ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "maa";
  };
})
