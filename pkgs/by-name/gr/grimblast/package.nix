{
  lib,
  fetchFromGitHub,
  bash,
  coreutils,
  glib,
  grim,
  hyprland,
  hyprpicker,
  jq,
  libnotify,
  makeWrapper,
  nix-update-script,
  scdoc,
  slurp,
  stdenvNoCC,
  unixtools,
  wl-clipboard,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "grimblast";
  version = "0.1-unstable-2026-06-30";

  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "contrib";
    rev = "3dcbce715ae8b93107fa8632db15bf976862a573";
    hash = "sha256-JP0D8r8o9+jnYk0/B5O722La+oZeC5iNQ3lonKFTmbQ=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
    scdoc
  ];

  buildInputs = [ bash ];

  makeFlags = [
    "PREFIX=$(out)"
  ];

  postInstall = ''
    wrapProgram $out/bin/grimblast --prefix PATH ':' \
      "${
        lib.makeBinPath [
          coreutils
          grim
          hyprland
          hyprpicker
          jq
          libnotify
          slurp
          wl-clipboard
          unixtools.getopt
          glib
        ]
      }"
  '';

  sourceRoot = "${finalAttrs.src.name}/grimblast";
  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Helper for screenshots within Hyprland, based on grimshot";
    homepage = "https://github.com/hyprwm/contrib";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "grimblast";
    teams = [ lib.teams.hyprland ];
  };
})
