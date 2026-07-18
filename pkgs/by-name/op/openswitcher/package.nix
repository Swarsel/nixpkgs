{
  lib,
  desktop-file-utils,
  fetchFromSourcehut,
  gobject-introspection,
  gtk3,
  libhandy,
  meson,
  ninja,
  pkg-config,
  python3Packages,
  scdoc,
  udevCheckHook,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "openswitcher";
  version = "0.13.0";

  src = fetchFromSourcehut {
    owner = "~martijnbraam";
    repo = "pyatem";
    rev = finalAttrs.version;
    hash = "sha256-eEn09e+ZED4DGEWTUou9CRgazngHIXZv51CLhX9YuBI=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    desktop-file-utils
    gobject-introspection
    gtk3
    meson
    ninja
    pkg-config
    scdoc
    wrapGAppsHook3
    udevCheckHook
  ];

  buildInputs = [
    gtk3
    libhandy
  ];

  propagatedBuildInputs = with python3Packages; [
    # for switcher-control, bmd-setup
    paho-mqtt
    pyatem
    pygobject3
    # for atemswitch
    requests
    # for openswitcher-proxy
    toml
  ];

  postInstall = ''
    install -Dm644 -t $out/lib/udev/rules.d/ $src/100-blackmagicdesign.rules
  '';

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  depsBuildBuild = [
    pkg-config
  ];

  dontWrapGApps = true;
  pyproject = false;

  meta = {
    description = "Blackmagic Design mixer control application";
    homepage = "https://openswitcher.org/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ hexa ];
    mainProgram = "switcher-control";
    downloadPage = "https://git.sr.ht/~martijnbraam/pyatem";
  };
})
