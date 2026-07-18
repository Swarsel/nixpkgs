{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoctor,
  curl,
  installShellFiles,
  libiconv,
  ncurses,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rink";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "tiffany352";
    repo = "rink-rs";
    rev = "v${finalAttrs.version}";
    hash = "sha256-JRXRN/jOwM3j59ckOcIlbLdSvV9PFueOPs/EVHCF8JE=";
  };

  nativeBuildInputs = [
    pkg-config
    installShellFiles
    asciidoctor
  ];

  buildInputs = [
    ncurses
  ]
  ++ (
    if stdenv.hostPlatform.isDarwin then
      [
        curl
        libiconv
      ]
    else
      [ openssl ]
  );

  cargoHash = "sha256-qbMnJjJQbNqs6AAgMjtqPEMxIDxdF5a8/tWAVW0Vrig=";

  postBuild = ''
    make man
  '';

  # Some tests fail and/or attempt to use internet servers.
  doCheck = false;

  postInstall = ''
    installManPage build/*
  '';

  meta = {
    description = "Unit-aware calculator";
    homepage = "https://rinkcalc.app";

    license = with lib.licenses; [
      mpl20
      gpl3Plus
    ];

    maintainers = with lib.maintainers; [
      sb0
      keysmashes
    ];

    mainProgram = "rink";
  };
})
