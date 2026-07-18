{
  lib,
  fetchFromGitHub,
  gdk-pixbuf,
  gettext,
  gobject-introspection,
  python3Packages,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "photocollage";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "adrienverge";
    repo = "PhotoCollage";
    rev = "v${finalAttrs.version}";
    hash = "sha256-YEkQ5yVFCBBFg8IL5ExvZIi0moaG/c0LtsIkphuzuog=";
  };

  nativeBuildInputs = [
    gettext
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    gdk-pixbuf
  ];

  postInstall = ''
    # Based on the debian package's list of files. Link:
    # https://packages.debian.org/bookworm/all/photocollage/filelist
    install -Dm0644 ./data/photocollage.desktop $out/share/applications/photocollage.desktop
    install -Dm0644 ./data/photocollage.appdata.xml $out/share/appdata/photocollage.appdata.xml
    cp -r ./data/icons $out/share/icons
  '';

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pillow
    pycairo
    pygobject3
  ];

  dontWrapGApps = true;
  pyproject = true;
  pythonImportsCheck = [ "photocollage" ];

  meta = {
    description = "Graphical tool to make photo collage posters";
    homepage = "https://github.com/adrienverge/PhotoCollage";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ eliandoran ];
    platforms = lib.platforms.linux;
    mainProgram = "photocollage";
  };
})
