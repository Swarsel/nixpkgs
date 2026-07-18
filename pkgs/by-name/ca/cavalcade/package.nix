{
  lib,
  fetchurl,
  fetchFromGitHub,
  cava,
  copyDesktopItems,
  gobject-introspection,
  gst_all_1,
  gtk3,
  makeDesktopItem,
  python3Packages,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "cavalcade";
  version = "0.8";

  src = fetchFromGitHub {
    owner = "worron";
    repo = "cavalcade";
    tag = finalAttrs.version;
    hash = "sha256-VyWOPNidN0+pfuxsgPWq6lI5gXQsiRpmYjQYjZW6i9w=";
  };

  postPatch = ''
    substituteInPlace cavalcade/cava.py \
      --replace-fail '"cava"' '"${cava}/bin/cava"'
  '';

  nativeBuildInputs = [
    wrapGAppsHook3
    copyDesktopItems
    gobject-introspection
    gst_all_1.gstreamer
  ];

  buildInputs = [ gtk3 ];
  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    pygobject3
    gst-python
    pillow
  ];

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "AudioVideo"
        "Audio"
        "GTK"
      ];

      comment = "CAVA GUI";
      desktopName = "Cavalcade";
      exec = "cavalcade";

      icon = fetchurl {
        hash = "sha256-GJR5kUmSnFG6dE+o2UWKaHmiKPZNDGZZqXCIP8o883M=";
        url = "https://raw.githubusercontent.com/worron/cavalcade/68ba5a2b2effd1c46b0568f4a27852689c2cdf32/desktop/cavalcade.svg";
      };

      name = "Cavalcade";
      type = "Application";
    })
  ];

  pyproject = true;

  meta = {
    description = "Python wrapper for C.A.V.A. utility with a GUI";
    homepage = "https://github.com/worron/cavalcade";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
