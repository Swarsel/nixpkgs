{
  lib,
  fetchFromGitHub,
  makeWrapper,
  mpv,
  pulseaudio,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "cplay-ng";
  version = "5.5.0";

  src = fetchFromGitHub {
    owner = "xi";
    repo = "cplay-ng";
    tag = finalAttrs.version;
    hash = "sha256-Pc2cneDGNE8EqRi21h/B25jGUZJteXlGxlRgbzcyVKM=";
  };

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/cplay-ng \
      --prefix PATH : ${
        lib.makeBinPath [
          mpv
          pulseaudio
        ]
      }
  '';

  build-system = [ python3Packages.setuptools ];
  pyproject = true;

  meta = {
    description = "Simple curses audio player";

    longDescription = ''
      cplay is a minimalist music player with a textual user interface written
      in Python. It aims to provide a power-user-friendly interface with simple
      filelist and playlist control.

      Instead of building an elaborate database of your music library, cplay
      allows you to quickly browse the filesystem and enqueue files,
      directories, and playlists.

      The original cplay was started by Ulf Betlehem in 1998 and is no longer
      maintained. This is a rewrite that aims to stay true to the original
      design while evolving with a shifting environment.
    '';

    homepage = "https://github.com/xi/cplay-ng";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ fgaz ];
    mainProgram = "cplay-ng";
  };
})
