{
  lib,
  fetchFromGitHub,
  aria2,
  catt,
  curl,
  ffmpeg,
  fzf,
  gnugrep,
  gnused,
  iina,
  makeWrapper,
  mpv,
  openssl,
  stdenvNoCC,
  syncplay,
  vlc,
  chromecastSupport ? false,
  syncSupport ? false,
  withIina ? false,
  withMpv ? true,
  withVlc ? false,
}:

let
  players = lib.optional withMpv mpv ++ lib.optional withVlc vlc ++ lib.optional withIina iina;
in

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ani-cli";
  version = "4.14";

  src = fetchFromGitHub {
    owner = "pystardust";
    repo = "ani-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OyCKDN89sBz59+3JncMDyNOq8UMqqjara+A0Owo3oko=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -Dm755 ani-cli $out/bin/ani-cli

    wrapProgram $out/bin/ani-cli \
      --prefix PATH : ${lib.makeBinPath finalAttrs.runtimeInputs} \
      ${lib.optionalString (builtins.length players > 0) "--suffix PATH : ${lib.makeBinPath players}"}

    runHook postInstall
  '';

  runtimeInputs = [
    openssl
    gnugrep
    gnused
    curl
    fzf
    ffmpeg
    aria2
  ]
  ++ lib.optional chromecastSupport catt
  ++ lib.optional syncSupport syncplay;

  meta = {
    description = "Cli tool to browse and play anime";
    homepage = "https://github.com/pystardust/ani-cli";
    license = lib.licenses.gpl3Plus;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
    ];

    maintainers = with lib.maintainers; [ skykanin ];
    platforms = lib.platforms.unix;
    mainProgram = "ani-cli";
  };
})
