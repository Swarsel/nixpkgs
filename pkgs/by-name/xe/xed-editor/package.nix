{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  gspell,
  gtk3,
  gtksourceview4,
  intltool,
  itstool,
  libpeas,
  libxml2,
  meson,
  ninja,
  pkg-config,
  python3,
  python3Packages,
  versionCheckHook,
  wrapGAppsHook3,
  xapp,
  xapp-symbolic-icons,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xed-editor";
  version = "3.8.9";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "xed";
    rev = finalAttrs.version;
    hash = "sha256-ZTrTCyyyUDbt+/kjb1+I/bOjwXcsYGYd5K9ebPjJTA8=";
  };

  patches = [
    # We patch gobject-introspection and meson to store absolute paths to libraries in typelibs
    # but that requires the install_dir is an absolute path.
    ./correct-gir-lib-path.patch
  ];

  nativeBuildInputs = [
    meson
    pkg-config
    intltool
    itstool
    ninja
    python3
    versionCheckHook
    wrapGAppsHook3
  ];

  buildInputs = [
    libxml2
    glib
    gtk3
    gtksourceview4
    libpeas
    gspell
    python3Packages.pygobject3
    xapp
  ];

  doInstallCheck = true;

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix XDG_DATA_DIRS : "${lib.makeSearchPath "share" [ xapp-symbolic-icons ]}"
    )
  '';

  versionCheckProgram = "${placeholder "out"}/bin/xed";

  meta = {
    description = "Light weight text editor from Linux Mint";
    homepage = "https://github.com/linuxmint/xed";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      tu-maurice
      bobby285271
    ];

    platforms = lib.platforms.linux;
    mainProgram = "xed";
  };
})
