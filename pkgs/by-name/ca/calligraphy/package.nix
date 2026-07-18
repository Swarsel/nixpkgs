{
  lib,
  fetchFromGitLab,
  desktop-file-utils,
  gobject-introspection,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "calligraphy";
  version = "1.2.0";

  src = fetchFromGitLab {
    owner = "GeopJr";
    repo = "Calligraphy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KDml96oxnmTygTC+3rZ//wKv7xDSjw37+UHu3a3zuO4=";
    domain = "gitlab.gnome.org";
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

  dependencies = with python3Packages; [
    pygobject3
    pyfiglet
  ];

  dontWrapGApps = true;
  makeWrapperArgs = [ "\${gappsWrapperArgs[@]}" ];
  pyproject = false; # Built with meson
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "GTK tool turning text into ASCII banners";
    homepage = "https://calligraphy.geopjr.dev";

    license = with lib.licenses; [
      gpl3Plus
      # and
      cc0
    ];

    maintainers = with lib.maintainers; [
      aleksana
      da157
    ];

    platforms = lib.platforms.linux;
    mainProgram = "calligraphy";
  };
})
