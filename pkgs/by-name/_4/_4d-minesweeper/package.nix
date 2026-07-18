{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  gcc-unwrapped,
  git,
  godot3-export-templates,
  godot3-headless,
  libGLU,
  libglvnd,
  libpulseaudio,
  libx11,
  libxcursor,
  libxext,
  libxfixes,
  libxi,
  libxinerama,
  libxrandr,
  libxrender,
  unzip,
  zlib,
}:

stdenv.mkDerivation {
  pname = "4d-minesweeper";
  version = "2.0";

  src = fetchFromGitHub {
    owner = "Alzager";
    repo = "4D-Minesweeper-Archived";
    rev = "db176d8aa5981a597bbae6a1a74aeebf0f376df4";
    hash = "sha256-A5QKqCo9TTdzmK13WRSAfkrkeUqHc4yQCzy4ZZ9uX2M=";
  };

  nativeBuildInputs = [
    godot3-headless
    unzip
  ];

  buildInputs = [
    alsa-lib
    gcc-unwrapped.lib
    git
    libGLU
    libx11
    libxcursor
    libxext
    libxfixes
    libxi
    libxinerama
    libxrandr
    libxrender
    libglvnd
    libpulseaudio
    zlib
  ];

  buildPhase = ''
    runHook preBuild

    # Cannot create file '/homeless-shelter/.config/godot/projects/...'
    export HOME=$TMPDIR

    # Link the export-templates to the expected location. The --export commands
    # expects the template-file at .../templates/3.2.3.stable/linux_x11_64_release
    # with 3.2.3 being the version of godot.
    mkdir -p $HOME/.local/share/godot
    ln -s ${godot3-export-templates}/share/godot/templates $HOME/.local/share/godot

    mkdir -p $out/bin/
    cd source/
    godot3-headless --export "Linux/X11" $out/bin/4d-minesweeper

    runHook postBuild
  '';

  dontFixup = true;
  dontInstall = true;
  dontStrip = true;

  meta = {
    description = "4D Minesweeper game written in Godot";
    homepage = "https://github.com/Alzager/4D-Minesweeper-Archived";
    license = lib.licenses.mpl20;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "4d-minesweeper";
  };
}
