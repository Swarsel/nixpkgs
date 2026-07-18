{
  lib,
  fetchFromGitHub,
  bash,
  callPackage,
  gobject-introspection,
  gtk4,
  libappindicator,
  pipewire,
  python3Packages,
  wrapGAppsHook4,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "pulsemeeter";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "theRealCarneiro";
    repo = "pulsemeeter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-m64frtEVqwJEc0rfKoPIbTJtASE+aPAdBBSrPNHIXRY=";
  };

  nativeBuildInputs = [
    wrapGAppsHook4
    gobject-introspection
  ];

  buildInputs = [
    libappindicator
    pipewire
    bash
    gtk4
  ];

  build-system = with python3Packages; [
    setuptools
    babel
  ];

  dependencies = with python3Packages; [
    pygobject3
    pydantic
    pulsectl
    pulsectl-asyncio
  ];

  dontWrapGApps = true;

  makeWrapperArgs = [
    "\${gappsWrapperArgs[@]}"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pulsemeeter" ];
  passthru.tests.version = callPackage ./version-test.nix { inherit (finalAttrs) version; };

  meta = {
    description = "Pulseaudio and pipewire audio mixer inspired by voicemeeter";
    homepage = "https://github.com/theRealCarneiro/pulsemeeter";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      therobot2105
    ];

    platforms = lib.platforms.linux;
    mainProgram = "pulsemeeter";
  };
})
