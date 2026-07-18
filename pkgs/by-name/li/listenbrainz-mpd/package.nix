{
  lib,
  stdenv,
  asciidoctor,
  fetchFromCodeberg,
  installShellFiles,
  libiconv,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  sqlite,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "listenbrainz-mpd";
  version = "2.5.1";

  src = fetchFromCodeberg {
    owner = "elomatreb";
    repo = "listenbrainz-mpd";
    rev = "v${finalAttrs.version}";
    hash = "sha256-087+l3calge6hKu3h84C98mIpW6qFAZwRMe4lkQCU4o=";
  };

  nativeBuildInputs = [
    pkg-config
    installShellFiles
    asciidoctor
  ];

  buildInputs = [
    sqlite
  ]
  ++ (
    if stdenv.hostPlatform.isDarwin then
      [
        libiconv
      ]
    else
      [
        openssl
      ]
  );

  cargoHash = "sha256-SxXEathWAGqdgeJmIn5h9Zvv7Z3DGXa4htkODf/ANRQ=";

  postInstall = ''
    installShellCompletion \
      --bash generated_completions/listenbrainz-mpd.bash \
      --fish generated_completions/listenbrainz-mpd.fish \
      --zsh generated_completions/_listenbrainz-mpd

    asciidoctor --backend=manpage listenbrainz-mpd.adoc -o listenbrainz-mpd.1
    installManPage listenbrainz-mpd.1
  '';

  buildFeatures = [
    "shell_completion"
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    "systemd"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "ListenBrainz submission client for MPD";
    homepage = "https://codeberg.org/elomatreb/listenbrainz-mpd";
    changelog = "https://codeberg.org/elomatreb/listenbrainz-mpd/src/tag/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      DeeUnderscore
      Kladki
    ];

    mainProgram = "listenbrainz-mpd";
  };
})
