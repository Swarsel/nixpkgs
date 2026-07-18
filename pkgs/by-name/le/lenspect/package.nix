{
  lib,
  fetchFromGitHub,
  blueprint-compiler,
  desktop-file-utils,
  glib-networking,
  gobject-introspection,
  libadwaita,
  libsecret,
  libsoup_3,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "lenspect";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "vmkspv";
    repo = "lenspect";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aGL6o9gv+z7Ey2XR8IZ/4gBXdDqGlaWaQXf0eVDEHlI=";
  };

  nativeBuildInputs = [
    blueprint-compiler
    desktop-file-utils
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    glib-networking
    libadwaita
    libsecret
    libsoup_3
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dependencies = with python3Packages; [
    pygobject3
  ];

  dontWrapGApps = true;
  pyproject = false;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Lightweight security threat scanner intended to make malware detection more accessible and efficient";
    homepage = "https://github.com/vmkspv/lenspect";
    changelog = "https://github.com/vmkspv/lenspect/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ RoGreat ];
    platforms = lib.platforms.linux;
    mainProgram = "lenspect";
  };
})
