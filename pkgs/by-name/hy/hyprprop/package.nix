{
  lib,
  fetchFromGitHub,
  bash,
  copyDesktopItems,
  coreutils,
  jq,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
  scdoc,
  slurp,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "hyprprop";
  version = "0.1-unstable-2026-02-19";

  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "contrib";
    rev = "918f266dddae39fa4184a1b8bf51ec5381cf29f7";
    hash = "sha256-aH8h5ZOiyEGtHmEyuE/eFxx8TN7a+NGDnl4V+dbzJ6E=";
  };

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    bash
    scdoc
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  postInstall = ''
    wrapProgram $out/bin/hyprprop --prefix PATH ':' \
      "${
        lib.makeBinPath [
          coreutils
          slurp
          jq
        ]
      }"
  '';

  desktopItems =
    let
      desktopItem = makeDesktopItem {
        desktopName = "Hyprprop";
        exec = "hyprprop";
        name = "hyprprop";
        startupNotify = false;
        terminal = true;
      };
    in
    [ desktopItem ];

  sourceRoot = "${finalAttrs.src.name}/hyprprop";
  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Xprop replacement for Hyprland";
    homepage = "https://github.com/hyprwm/contrib";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "hyprprop";
    teams = [ lib.teams.hyprland ];
  };
})
