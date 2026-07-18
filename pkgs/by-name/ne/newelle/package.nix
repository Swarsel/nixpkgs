{
  lib,
  fetchFromGitHub,
  bash,
  desktop-file-utils,
  ffmpeg,
  gobject-introspection,
  gsettings-desktop-schemas,
  gtksourceview5,
  libadwaita,
  lsb-release,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3Packages,
  vte-gtk4,
  webkitgtk_6_0,
  wrapGAppsHook4,
}:

let
  version = "1.4.5";
in
python3Packages.buildPythonApplication {
  inherit version;
  pname = "newelle";

  src = fetchFromGitHub {
    owner = "qwersyk";
    repo = "Newelle";
    tag = version;
    hash = "sha256-GcNAwrk5y6F0BgRy69nRePkX4WoYviWsB+8X/+N5QwE=";
  };

  postPatch = ''
    substituteInPlace src/utility/pip.py \
      --replace-fail "# Manage pip path locking" "return None"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    gobject-introspection
    wrapGAppsHook4
    desktop-file-utils
    pkg-config
  ];

  buildInputs = [
    libadwaita
    vte-gtk4
    gsettings-desktop-schemas
    gtksourceview5
    webkitgtk_6_0
  ];

  dependencies = with python3Packages; [
    pygobject3
    libxml2
    pydub
    gtts
    speechrecognition
    numpy
    matplotlib
    pylatexenc
    pyaudio
    pip-install-test
    newspaper3k
    tiktoken
    openai
    ollama
    llama-index-core
    llama-index-readers-file
    google-genai
    anthropic
  ];

  dontWrapGApps = true;

  makeWrapperArgs = [
    "\${gappsWrapperArgs[@]}"
    "--prefix PATH : ${
      lib.makeBinPath [
        lsb-release
        bash
        ffmpeg
      ]
    }"
  ];

  postInstallCheck = ''
    mesonCheckPhase
  '';

  pyproject = false; # uses meson
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Ultimate Virtual Assistant";
    homepage = "https://github.com/qwersyk/Newelle";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      michaelAllen
    ];

    platforms = lib.platforms.linux;
    mainProgram = "newelle";
  };
}
