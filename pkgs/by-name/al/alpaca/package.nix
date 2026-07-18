{
  lib,
  fetchFromGitHub,
  appstream,
  bash,
  blueprint-compiler,
  desktop-file-utils,
  glib-networking,
  gobject-introspection,
  gtksourceview5,
  libadwaita,
  libportal,
  libspelling,
  meson,
  ninja,
  nix-update-script,
  ollama,
  pipewire,
  pkg-config,
  python3Packages,
  vte-gtk4,
  webkitgtk_6_0,
  wrapGAppsHook4,
  xdg-utils,
}:

let
  pythonPackages = python3Packages.overrideScope (
    self: super: {
      bibtexparser = self.bibtexparser_2;
    }
  );
in
pythonPackages.buildPythonApplication rec {
  pname = "alpaca";
  version = "9.2.4";

  src = fetchFromGitHub {
    owner = "Jeffser";
    repo = "Alpaca";
    tag = version;
    hash = "sha256-rZ1H4QfxkBo+fVFCDODaio+1NEwRVjIY388Q9sR8qO4=";
  };

  postPatch = ''
    substituteInPlace src/widgets/activities/terminal.py \
      --replace-fail "['bash', '-c', ';\n'.join(self.prepare_script())]," "['${bash}/bin/bash', '-c', ';\n'.join(self.prepare_script())],"
  '';

  nativeBuildInputs = [
    appstream
    meson
    ninja
    pkg-config
    gobject-introspection
    wrapGAppsHook4
    desktop-file-utils
    blueprint-compiler
  ];

  buildInputs = [
    libadwaita
    gtksourceview5
    vte-gtk4
    libspelling
    libportal
    webkitgtk_6_0
    pipewire # pipewiresrc
    glib-networking
  ];

  dependencies =
    with pythonPackages;
    [
      pygobject3
      requests
      pillow
      html2text
      youtube-transcript-api
      pydbus
      odfpy
      pyicu
      matplotlib
      openai
      markitdown
      gst-python
      opencv4
      zstandard
      pythonPackages.ollama
    ]
    ++ lib.concatAttrValues optional-dependencies;

  dontWrapGApps = true;

  makeWrapperArgs = [
    "\${gappsWrapperArgs[@]}"
    "--prefix PATH : ${
      lib.makeBinPath [
        xdg-utils
        ollama
      ]
    }"
  ];

  optional-dependencies = with pythonPackages; {
    image-tools = [ rembg ];

    speech-to-text = [
      openai-whisper
      pyaudio
    ];

    text-to-speech = [
      kokoro
      sounddevice
      spacy-models.en_core_web_sm
    ];
  };

  pyproject = false; # Built with meson
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Ollama client made with GTK4 and Adwaita";

    longDescription = ''
      To run Alpaca with GPU acceleration enabled, simply override it:
      ```nix
      pkgs.alpaca.override {
        ollama = pkgs.ollama-cuda;
      }
      ```
      Or using `pkgs.ollama-rocm` for AMD GPUs.
      For a vendor agnostic solution, use: `pkgs.ollama-vulkan`.
    '';

    homepage = "https://jeffser.com/alpaca";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      aleksana
      Gliczy
    ];

    platforms = lib.platforms.unix;
    mainProgram = "alpaca";
  };
}
