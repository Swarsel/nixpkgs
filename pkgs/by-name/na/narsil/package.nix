{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_image,
  SDL2_mixer,
  SDL2_ttf,
  autoreconfHook,
  ncurses,
  nix-update-script,
  enableSdl2 ? true,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "narsil";
  version = "1.4.0-143-g086e3b6af";

  src = fetchFromGitHub {
    owner = "NickMcConnell";
    repo = "NarSil";
    tag = finalAttrs.version;
    hash = "sha256-/6SOftTmm0EWccyxRzBHkIAVqPz37Ga6kuJL03gMTqo=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [
    ncurses
  ]
  ++ lib.optionals enableSdl2 [
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_ttf
  ];

  configureFlags = lib.optional enableSdl2 "--enable-sdl2";
  enableParallelBuilding = true;
  installFlags = [ "bindir=$(out)/bin" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Unofficial rewrite of Sil, a roguelike influenced by Angband";

    longDescription = ''
      NarSil attempts to be an almost-faithful recreation of Sil 1.3.0,
      but based on the codebase of modern Angband.
    '';

    homepage = "https://github.com/NickMcConnell/NarSil/";
    changelog = "https://github.com/NickMcConnell/NarSil/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl2;

    maintainers = with lib.maintainers; [
      nanotwerp
      x123
    ];

    mainProgram = "narsil";
  };
})
