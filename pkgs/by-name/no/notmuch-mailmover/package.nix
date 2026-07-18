{
  lib,
  fetchFromGitHub,
  installShellFiles,
  lua5_4,
  nix-update-script,
  notmuch,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "notmuch-mailmover";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "michaeladler";
    repo = "notmuch-mailmover";
    rev = "v${finalAttrs.version}";
    hash = "sha256-fJljqNSPLM1JiyeGMNvub/4wk5L9+lVTqtgCdoe7S88=";
  };

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ];

  buildInputs = [
    notmuch
    lua5_4
  ];

  cargoHash = "sha256-PeSlErwGBCZECYoWqmJrlRY7peNNY7c/wxd6R09uUz4=";

  postInstall = ''
    installManPage share/notmuch-mailmover.1.gz

    mkdir -p $out/share/notmuch-mailmover
    cp -dR example $out/share/notmuch-mailmover/

    installShellCompletion --cmd notmuch-mailmover \
      --bash share/notmuch-mailmover.bash \
      --fish share/notmuch-mailmover.fish \
      --zsh share/_notmuch-mailmover
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Application to assign notmuch tagged mails to IMAP folders";
    homepage = "https://github.com/michaeladler/notmuch-mailmover/";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      michaeladler
      archer-65
    ];

    platforms = lib.platforms.all;
    mainProgram = "notmuch-mailmover";
  };
})
