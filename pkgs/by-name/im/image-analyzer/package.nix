{
  lib,
  fetchurl,
  adwaita-icon-theme,
  cmake,
  gdk-pixbuf,
  gnuplot,
  gobject-introspection,
  intltool,
  libmirage,
  libxml2,
  pkg-config,
  python3Packages,
  wrapGAppsHook3,
  writeScript,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "image-analyzer";
  version = "3.3.1";

  src = fetchurl {
    url = "mirror://sourceforge/cdemu/image-analyzer-${finalAttrs.version}.tar.xz";
    hash = "sha256-vsfDmtjrvAC49ynnJ7QguBfSVnt/sBpCy/Eau2l1/jQ=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapGAppsHook3
    intltool
    gobject-introspection
  ];

  buildInputs = [
    libxml2
    gnuplot
    libmirage
    adwaita-icon-theme
    gdk-pixbuf
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
    matplotlib
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dontWrapGApps = true;
  pyproject = false;

  passthru = {
    updateScript = writeScript "update-image-analyzer" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl pcre2 common-updater-scripts

      set -eu -o pipefail

      # Fetch the latest version from the SourceForge RSS feed for image-analyzer
      newVersion="$(curl -s "https://sourceforge.net/projects/cdemu/rss?path=/image-analyzer" | pcre2grep -o1 'image-analyzer-([0-9.]+)\.tar\.xz' | head -n 1)"

      update-source-version image-analyzer "$newVersion"
    '';
  };

  meta = {
    description = "Suite of tools for emulating optical drives and discs";

    longDescription = ''
      CDEmu consists of:

      - a kernel module implementing a virtual drive-controller
      - libmirage which is a software library for interpreting optical disc images
      - a daemon which emulates the functionality of an optical drive+disc
      - textmode and GTK clients for controlling the emulator
      - an image analyzer to view the structure of image files

      Optical media emulated by CDemu can be mounted within Linux. Automounting is also allowed.
    '';

    homepage = "https://cdemu.sourceforge.io/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ bendlas ];
    platforms = lib.platforms.linux;
  };
})
