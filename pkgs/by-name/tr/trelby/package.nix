{
  lib,
  fetchFromGitHub,
  glib,
  gsettings-desktop-schemas,
  gtk3,
  python3Packages,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "trelby";
  version = "2.4.16.2";

  src = fetchFromGitHub {
    owner = "trelby";
    repo = "trelby";
    tag = finalAttrs.version;
    hash = "sha256-YblilPQXjlSgkBstewfiuW0DZCnJw4dk6vZfEhdBGbk=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gsettings-desktop-schemas
    gtk3
  ];

  postInstall = ''
    install -Dm644 trelby/resources/trelby.desktop $out/share/applications/trelby.desktop

    install -Dm644 trelby/resources/icon256.png $out/share/icons/hicolor/256x256/apps/trelby.png

    substituteInPlace $out/share/applications/trelby.desktop \
      --replace-fail "Icon=trelby256" "Icon=trelby"
  '';

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = with python3Packages; [
    lxml
    reportlab
    wxpython
  ];

  pyproject = true;

  meta = {
    description = "Free, multiplatform, feature-rich screenwriting program";
    homepage = "https://www.trelby.org";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ isotoxal ];
    platforms = lib.platforms.linux;
    mainProgram = "trelby";
    downloadPage = "https://github.com/trelby/trelby";
  };
})
