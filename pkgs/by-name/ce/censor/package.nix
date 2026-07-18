{
  lib,
  desktop-file-utils,
  fetchFromCodeberg,
  gobject-introspection,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "censor";
  version = "0.7.2";

  src = fetchFromCodeberg {
    owner = "censor";
    repo = "Censor";
    tag = "v${finalAttrs.version}";
    hash = "sha256-444EGJCNnRRkuTzm4HdapUvwphx9EavxeyAI0Sxh8G8=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    wrapGAppsHook4
    desktop-file-utils
  ];

  buildInputs = [
    libadwaita
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dependencies = with python3Packages; [
    pygobject3
    pymupdf
  ];

  dontWrapGApps = true;
  pyproject = false;

  meta = {
    description = "PDF document redaction for the GNOME desktop";
    homepage = "https://codeberg.org/censor/Censor";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ onny ];
    mainProgram = "censor";
  };
})
