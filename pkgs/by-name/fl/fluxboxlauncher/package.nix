{
  lib,
  fetchFromGitHub,
  atk,
  fluxbox,
  gdk-pixbuf,
  gettext,
  glibcLocales,
  gobject-introspection,
  gtk3,
  pango,
  python3,
  wrapGAppsHook3,
}:

python3.pkgs.buildPythonApplication {
  pname = "fluxboxlauncher";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "mothsart";
    repo = "fluxboxlauncher";
    rev = "0.2.1";
    sha256 = "024h1dk0bhc5s4dldr6pqabrgcqih9p8cys5lqgkgz406y4vyzvf";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
    pango
    gdk-pixbuf
    atk
    gettext
  ];

  buildInputs = [
    glibcLocales
    gtk3
    python3
    fluxbox
  ];

  postInstall = ''
    install -Dm444 fluxboxlauncher.desktop -t $out/share/applications
    install -Dm444 fluxboxlauncher.svg -t $out/share/icons/hicolor/scalable/apps
  '';

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    pygobject3
  ];

  makeWrapperArgs = [
    "--set LOCALE_ARCHIVE ${glibcLocales}/lib/locale/locale-archive"
    "--set CHARSET en_us.UTF-8"
  ];

  pyproject = true;

  meta = {
    description = "Gui editor (gtk) to configure applications launching on a fluxbox session";
    homepage = "https://github.com/mothsART/fluxboxlauncher";
    license = lib.licenses.bsdOriginal;
    maintainers = with lib.maintainers; [ mothsart ];
    platforms = lib.platforms.linux;
    mainProgram = "fluxboxlauncher";
  };
}
