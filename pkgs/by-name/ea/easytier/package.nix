{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  mold,
  nix-update-script,
  nixosTests,
  protobuf,
  rustPlatform,
  withQuic ? false, # with QUIC protocol support
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "easytier";
  version = "2.6.4";

  src = fetchFromGitHub {
    owner = "EasyTier";
    repo = "EasyTier";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lwqpOVKFm85AiBb7NWLAkjSrWSe5pzF0AuEmmDo+v0k=";
  };

  nativeBuildInputs = [
    protobuf
    rustPlatform.bindgenHook
    installShellFiles
    mold
  ];

  cargoHash = "sha256-c+rOjokrL0U63s1CMfy6KlGI7VoSmtxuQjBNDAagSdg=";
  doCheck = false; # tests failed due to heavy rely on network

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd easytier-cli \
      --bash <($out/bin/easytier-cli gen-autocomplete bash) \
      --fish <($out/bin/easytier-cli gen-autocomplete fish) \
      --zsh <($out/bin/easytier-cli gen-autocomplete zsh)
    installShellCompletion --cmd easytier-core \
      --bash <($out/bin/easytier-core --gen-autocomplete bash) \
      --fish <($out/bin/easytier-core --gen-autocomplete fish) \
      --zsh <($out/bin/easytier-core --gen-autocomplete zsh)
  '';

  buildFeatures = lib.optional stdenv.hostPlatform.isMips "mips" ++ lib.optional withQuic "quic";
  buildNoDefaultFeatures = stdenv.hostPlatform.isMips;

  passthru = {
    tests = { inherit (nixosTests) easytier; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Simple, decentralized mesh VPN with WireGuard support";

    longDescription = ''
      EasyTier is a simple, safe and decentralized VPN networking solution implemented
      with the Rust language and Tokio framework.
    '';

    homepage = "https://github.com/EasyTier/EasyTier";
    changelog = "https://github.com/EasyTier/EasyTier/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ltrump ];
    platforms = with lib.platforms; unix ++ windows;
    mainProgram = "easytier-core";
  };
})
