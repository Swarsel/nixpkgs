{
  lib,
  fetchFromGitHub,
  gobject-introspection,
  gtk3,
  makeDesktopItem,
  pulseaudio,
  python3Packages,
  sox,
  wrapGAppsHook3,
}:
let
  desktopItem = makeDesktopItem {
    categories = [
      "AudioVideo"
      "Audio"
    ];

    desktopName = "Lyrebird";
    exec = "lyrebird";
    genericName = "Voice Changer";
    icon = "${placeholder "out"}/share/lyrebird/icon.png";
    name = "lyrebird";
  };
in
python3Packages.buildPythonApplication rec {
  pname = "lyrebird";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "lyrebird-voice-changer";
    repo = "lyrebird";
    tag = "v${version}";
    sha256 = "sha256-VIYcOxvSpzRvJMzEv2i5b7t0WMF7aQxB4Y1jfvuZN/Y=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    gtk3
    sox
  ];

  propagatedBuildInputs = with python3Packages; [
    toml
    pygobject3
  ];

  doCheck = false;

  installPhase = ''
    mkdir -p $out/{bin,share/{applications,lyrebird}}
    cp -at $out/share/lyrebird/ app icon.png
    cp -at $out/share/applications/ ${desktopItem}
    install -Dm755 app.py $out/bin/lyrebird
  '';

  dontWrapGApps = true;

  makeWrapperArgs = [
    "--prefix 'PATH' ':' '${
      lib.makeBinPath [
        sox
        pulseaudio
      ]
    }'"
    "--prefix 'PYTHONPATH' ':' '${placeholder "out"}/share/lyrebird'"
    "--chdir '${placeholder "out"}/share/lyrebird'"
    ''"''${gappsWrapperArgs[@]}"''
  ];

  pyproject = false;

  meta = {
    description = "Simple and powerful voice changer for Linux, written in GTK 3";
    homepage = "https://github.com/lyrebird-voice-changer/lyrebird";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ OPNA2608 ];
    platforms = lib.platforms.linux;
    mainProgram = "lyrebird";
  };
}
