{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ffmpeg-full,
  glfw,
  gtk3,
  libnotify,
  libx11,
  libxcursor,
  libxinerama,
  libxrandr,
  makeWrapper,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "midivisualizer";
  version = "7.3";

  src = fetchFromGitHub {
    owner = "kosua20";
    repo = "MIDIVisualizer";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-ljDdbpvXJXv7YPgxwXELee06NNOwqIBP8C/IbL7qBuk=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    glfw
    ffmpeg-full
    libnotify
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libx11
    libxrandr
    libxinerama
    libxcursor
    gtk3
  ];

  installPhase =
    if stdenv.hostPlatform.isDarwin then
      ''
        mkdir -p $out/Applications $out/bin
        cp -r MIDIVisualizer.app $out/Applications/
        ln -s ../Applications/MIDIVisualizer.app/Contents/MacOS/MIDIVisualizer $out/bin/
      ''
    else
      ''
        mkdir -p $out/bin
        cp MIDIVisualizer $out/bin

        wrapProgram $out/bin/MIDIVisualizer \
          --prefix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS"
      '';

  meta = {
    description = "Small MIDI visualizer tool, using OpenGL";
    homepage = "https://github.com/kosua20/MIDIVisualizer";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.ericdallo ];
    platforms = lib.platforms.unix;
    mainProgram = "MIDIVisualizer";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
