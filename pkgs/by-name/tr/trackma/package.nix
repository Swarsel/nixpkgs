{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  glib,
  gobject-introspection,
  gtk3,
  imagemagick,
  makeDesktopItem,
  python3,
  qt5,
  wrapGAppsHook3,
  withCurses ? false,
  withGTK ? false,
  withQT ? false,
}:
let
  mkDesktopItem =
    name: desktopName: comment: terminal:
    makeDesktopItem {
      inherit
        name
        desktopName
        comment
        terminal
        ;

      categories = [ "Network" ];
      exec = name + " %u";
      icon = "trackma";
      type = "Application";
    };
in
python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "trackma";
  version = "0.10.3";

  src = fetchFromGitHub {
    owner = "z411";
    repo = "trackma";
    tag = "v${finalAttrs.version}";
    sha256 = "HiHeq8mLNT54BWXXwOfeY+c+wGHWnlN5rA2WgXdrRY8=";
    fetchSubmodules = true; # for anime-relations submodule
  };

  nativeBuildInputs = [
    copyDesktopItems
    python3.pkgs.poetry-core
    imagemagick
  ]
  ++ lib.optionals withGTK [
    wrapGAppsHook3
    gobject-introspection
  ]
  ++ lib.optionals withQT [ qt5.wrapQtAppsHook ];

  buildInputs = lib.optionals withGTK [
    glib
    gtk3
  ];

  propagatedBuildInputs =
    with python3.pkgs;
    (
      [ requests ]
      ++ lib.optionals withQT [ pyqt5 ]
      ++ lib.optionals withGTK [
        pycairo
        pygobject3
      ]
      ++ lib.optionals withCurses [ urwid ]
      ++ lib.optionals stdenv.hostPlatform.isLinux [
        pydbus
        pyinotify
      ]
      ++ lib.optionals (withGTK || withQT) [ pillow ]
    );

  doCheck = false;

  postInstall = ''
    mkdir -p $out/share/icons/hicolor/64x64/apps
    magick $src/trackma/data/icon.png -resize 64x64! $out/share/icons/hicolor/64x64/apps/trackma.png
  '';

  preFixup =
    lib.optional withQT "wrapQtApp $out/bin/trackma-qt"
    ++ lib.optional withGTK "wrapGApp $out/bin/trackma-gtk";

  desktopItems =
    lib.optional withQT (
      mkDesktopItem "trackma-qt" "Trackma (Qt)" "Trackma Updater (Qt-frontend)" false
    )
    ++ lib.optional withGTK (
      mkDesktopItem "trackma-gtk" "Trackma (GTK)" "Trackma Updater (Gtk-frontend)" false
    )
    ++ lib.optional withCurses (
      mkDesktopItem "trackma-curses" "Trackma (ncurses)" "Trackma Updater (ncurses frontend)" true
    );

  dontWrapGApps = true;
  dontWrapQtApps = true;

  postDist =
    lib.optional (!withQT) "rm $out/bin/trackma-qt"
    ++ lib.optional (!withGTK) "rm $out/bin/trackma-gtk"
    ++ lib.optional (!withCurses) "rm $out/bin/trackma-curses";

  pyproject = true;
  pythonImportsCheck = [ "trackma" ];
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Open multi-site list manager for Unix-like systems (ex-wMAL)";
    homepage = "https://github.com/z411/trackma";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
