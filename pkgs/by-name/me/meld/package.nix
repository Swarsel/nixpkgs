{
  lib,
  stdenv,
  fetchurl,
  adwaita-icon-theme,
  desktop-file-utils,
  desktopToDarwinBundle,
  gettext,
  gnome,
  gobject-introspection,
  gsettings-desktop-schemas,
  gtk3,
  gtksourceview4,
  itstool,
  libxml2,
  meson,
  ninja,
  pkg-config,
  python3,
  wrapGAppsHook3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "meld";
  version = "3.23.1";

  src = fetchurl {
    url = "mirror://gnome/sources/meld/${lib.versions.majorMinor finalAttrs.version}/meld-${finalAttrs.version}.tar.xz";
    hash = "sha256-c/gnkkZjx8a0UadMg4UwTZn+qhPIH04KFx2ll8aENXQ=";
  };

  postPatch = ''
    patchShebangs meson_shebang_normalisation.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    gettext
    itstool
    libxml2
    pkg-config
    desktop-file-utils
    gobject-introspection
    wrapGAppsHook3
    gtk3 # for gtk-update-icon-cache
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ desktopToDarwinBundle ];

  buildInputs = [
    gtk3
    gtksourceview4
    gsettings-desktop-schemas
    adwaita-icon-theme
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dontWrapGApps = true;
  pyproject = false;

  pythonPath = with python3.pkgs; [
    pygobject3
    pycairo
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "meld";
      versionPolicy = "none"; # should be odd-unstable but we are tracking unstable versions for now
    };
  };

  meta = {
    description = "Visual diff and merge tool";
    homepage = "https://meld.app/";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      jtojnar
      mimame
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "meld";
  };
})
