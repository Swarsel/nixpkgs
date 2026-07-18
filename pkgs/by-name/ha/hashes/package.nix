{
  lib,
  fetchFromGitHub,
  adwaita-icon-theme,
  appstream,
  cmake,
  desktop-file-utils,
  glib,
  gobject-introspection,
  gtk4,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "hashes";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "zefr0x";
    repo = "hashes";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PbS0WOrolPz67kdx+wnyp8owBEwvRYXfqYQZcEmKZZQ=";
  };

  nativeBuildInputs = [
    meson
    ninja
    desktop-file-utils
    cmake
    pkg-config
    appstream
    gobject-introspection
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    libadwaita
    glib
    adwaita-icon-theme
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dependencies = with python3Packages; [
    name-that-hash
    pygobject3
  ];

  dontWrapGApps = true;
  pyproject = false;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Simple hash algorithm identification GUI";
    homepage = "https://github.com/zefr0x/hashes/tree/main";
    changelog = "https://github.com/zefr0x/hashes/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = lib.platforms.unix;
    mainProgram = "hashes";
  };
})
