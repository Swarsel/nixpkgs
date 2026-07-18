{
  lib,
  stdenv,
  fetchFromGitLab,
  coreutils,
  findutils,
  gnugrep,
  jre,
  libGL,
  libpulseaudio,
  makeWrapper,
  nix-update-script,
  openssl,
  util-linux,
  wget,
  which,
  zenity,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pokemmo-installer";
  version = "1.4.8";

  src = fetchFromGitLab {
    owner = "coringao";
    repo = "pokemmo-installer";
    tag = finalAttrs.version;
    hash = "sha256-uSbnXBpkeGM9X6DU7AikT7hG/emu67PXuGdm6xfB8To=";
  };

  nativeBuildInputs = [ makeWrapper ];

  postFixup = ''
    wrapProgram "$out/bin/pokemmo-installer" \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          findutils
          gnugrep
          jre
          openssl
          util-linux
          wget
          which
          zenity
        ]
      } \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libGL
          libpulseaudio
        ]
      }
  '';

  installFlags = [
    "PREFIX=${placeholder "out"}"

    # BINDIR defaults to $(PREFIX)/games
    "BINDIR=${placeholder "out"}/bin"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Installer and Launcher for the PokeMMO emulator";
    homepage = "https://pokemmo.eu";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ kira-bruneau ];
    platforms = lib.platforms.linux;
    mainProgram = "pokemmo-installer";
  };
})
