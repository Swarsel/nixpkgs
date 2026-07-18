{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  libiconv,
  nix-update-script,
  rustPlatform,
  shared-mime-info,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "handlr-regex";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "Anomalocaridid";
    repo = "handlr-regex";
    rev = "v${finalAttrs.version}";
    hash = "sha256-7psjlu0qyoZYTVwq2JYJJkB76ejlmMtmstDw+liMcj8=";
  };

  nativeBuildInputs = [
    installShellFiles
    shared-mime-info
  ];

  buildInputs = [ libiconv ];
  cargoHash = "sha256-a91WaIFBS9Rh4T/dwpLQJMoE604Tj0mVN38RKmNcZU0=";

  preCheck = ''
    export HOME=$TEMPDIR
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd handlr \
      --zsh <(COMPLETE=zsh $out/bin/handlr) \
      --bash <(COMPLETE=bash $out/bin/handlr) \
      --fish <(COMPLETE=fish $out/bin/handlr)

    installManPage target/release-tmp/build/handlr-regex-*/out/manual/man1/*
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fork of handlr with support for regex";
    homepage = "https://github.com/Anomalocaridid/handlr-regex";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ anomalocaris ];
    mainProgram = "handlr";
  };
})
