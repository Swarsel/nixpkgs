{
  lib,
  fetchFromGitHub,
  adwaita-icon-theme,
  copyDesktopItems,
  gdk-pixbuf,
  gobject-introspection,
  gsettings-desktop-schemas,
  makeDesktopItem,
  python3Packages,
  wrapGAppsHook3,
}:
let
  version = "2.67.0";
in
python3Packages.buildPythonApplication rec {
  inherit version;
  pname = "pyfa";

  src = fetchFromGitHub {
    owner = "pyfa-org";
    repo = "Pyfa";
    tag = "v${version}";
    hash = "sha256-LS8KW6dZe/CYdA1LvZlq1vL8YllnDZkD9WEEDOToY1M=";
  };

  nativeBuildInputs = [
    python3Packages.pyinstaller
    gobject-introspection
    wrapGAppsHook3
    copyDesktopItems
  ];

  buildInputs = [
    gsettings-desktop-schemas
    adwaita-icon-theme
    gdk-pixbuf
  ];

  buildPhase = ''
    runHook preBuild

    pyinstaller --clean --noconfirm pyfa.spec

    runHook postBuild
  '';

  doCheck = true;

  #
  # pyinstaller builds up dist/pyfa/pyfa binary and
  # dist/pyfa/apps directory with libraries and everything else.
  # creating a symbolic link out in $out/bin to $out/share/pyfa to avoid
  # exposing the innards of pyfa to the rest of the env.
  #
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/icons/hicolor/64x64/apps/

    cp -r dist/pyfa $out/share/
    cp imgs/gui/pyfa64.png $out/share/icons/hicolor/64x64/apps/pyfa.png
    ln -sf $out/share/pyfa/pyfa $out/bin/pyfa

    runHook postInstall
  '';

  build-system = [ python3Packages.setuptools ];

  configurePhase = ''
    runHook preConfigure

    python3 db_update.py

    runHook postConfigure
  '';

  dependencies = with python3Packages; [
    wxpython
    logbook
    matplotlib
    python-dateutil
    requests
    sqlalchemy_1_4
    cryptography
    markdown2
    beautifulsoup4
    pyaml
    roman
    numpy
    python-jose
    requests-cache
    pygobject3
  ];

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      desktopName = "pyfa";
      exec = "pyfa %U";
      genericName = "Python fitting assistant for Eve Online";
      icon = "pyfa";
      name = "pyfa";
    })
  ];

  dontWrapGApps = true;

  fixupPhase = ''
    runHook preFixup

    wrapProgramShell $out/share/pyfa/pyfa \
      ''${gappsWrapperArgs[@]} \

    runHook postFixup
  '';

  #
  # upstream does not include setup.py
  #
  patchPhase = ''
    cat > setup.py <<EOF
      from setuptools import setup
      setup(
        name = "pyfa",
        version = "${version}",
        scripts = ["pyfa.py"],
        packages = setuptools.find_packages(),
      )
    EOF
  '';

  pyproject = false;

  meta = {
    description = "Python fitting assistant, cross-platform fitting tool for EVE Online";
    homepage = "https://github.com/pyfa-org/Pyfa";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      toasteruwu
      cholli
      paschoal
    ];

    platforms = lib.platforms.linux;
    mainProgram = "pyfa";
  };
}
