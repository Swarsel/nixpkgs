{
  lib,
  stdenv,
  fetchFromGitHub,
  libsForQt5,
  makeDesktopItem,
  makeWrapper,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "leo-editor";
  version = "6.8.8";

  src = fetchFromGitHub {
    owner = "leo-editor";
    repo = "leo-editor";
    tag = "v${finalAttrs.version}";
    hash = "sha256-A7eFYdmKd4E515xRI4fuLs8wuC9sZu1qd2qMZXs7Ko0=";
  };

  nativeBuildInputs = [
    libsForQt5.wrapQtAppsHook
    makeWrapper
    python3
  ];

  propagatedBuildInputs = with python3.pkgs; [
    pyqt6
    docutils
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/icons/hicolor/32x32/apps"
    cp leo/Icons/leoapp32.png "$out/share/icons/hicolor/32x32/apps"

    mkdir -p "$out/share/applications"
    cp $desktopItem/share/applications/* $out/share/applications

    mkdir -p $out/share/leo-editor
    mv * $out/share/leo-editor

    makeWrapper ${python3.interpreter} $out/bin/leo \
      --set PYTHONPATH "$PYTHONPATH:$out/share/leo-editor" \
      --add-flags "-O $out/share/leo-editor/launchLeo.py"

    wrapQtApp $out/bin/leo

    runHook postInstall
  '';

  desktopItem = makeDesktopItem {
    categories = [
      "Application"
      "Development"
      "IDE"
    ];

    comment = finalAttrs.meta.description;
    desktopName = "Leo";
    exec = "leo %U";
    genericName = "Text Editor";
    icon = "leoapp32";

    mimeTypes = [
      "text/plain"
      "text/asp"
      "text/x-c"
      "text/x-script.elisp"
      "text/x-fortran"
      "text/html"
      "application/inf"
      "text/x-java-source"
      "application/x-javascript"
      "application/javascript"
      "text/ecmascript"
      "application/x-ksh"
      "text/x-script.ksh"
      "application/x-tex"
      "text/x-script.rexx"
      "text/x-pascal"
      "text/x-script.perl"
      "application/postscript"
      "text/x-script.scheme"
      "text/x-script.guile"
      "text/sgml"
      "text/x-sgml"
      "application/x-bsh"
      "application/x-sh"
      "application/x-shar"
      "text/x-script.sh"
      "application/x-tcl"
      "text/x-script.tcl"
      "application/x-texinfo"
      "application/xml"
      "text/xml"
      "text/x-asm"
    ];

    name = "leo-editor";
    startupNotify = false;
    type = "Application";
  };

  dontBuild = true;

  meta = {
    description = "Powerful folding editor";
    longDescription = "Leo is a PIM, IDE and outliner that accelerates the work flow of programmers, authors and web designers.";
    homepage = "https://leo-editor.github.io/leo-editor/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      leonardoce
      kashw2
    ];

    mainProgram = "leo";
  };
})
