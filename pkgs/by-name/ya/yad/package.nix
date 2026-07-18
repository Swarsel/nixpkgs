{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gtk3,
  hicolor-icon-theme,
  intltool,
  netpbm,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "yad";
  version = "14.1";

  src = fetchFromGitHub {
    owner = "v1cont";
    repo = "yad";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-Y7bp20fkNdSgBcSV1kPEpWEP7ASwZcScVRaPauwI72M=";
  };

  # FIXME: remove when gettext is fixed
  patches = [ ./gettext-0.25.patch ];

  postPatch = ''
    sed -i src/file.c -e '21i#include <glib/gprintf.h>'
    sed -i src/form.c -e '21i#include <stdlib.h>'

    # there is no point to bring in the whole netpbm package just for this file
    install -Dm644 ${netpbm.out}/share/netpbm/misc/rgb.txt $out/share/yad/rgb.txt
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    intltool
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    hicolor-icon-theme
  ];

  configureFlags = [
    "--enable-icon-browser"
    "--with-gtk=gtk3"
    "--with-rgb=${placeholder "out"}/share/yad/rgb.txt"
  ];

  postAutoreconf = ''
    intltoolize
  '';

  meta = {
    description = "GUI dialog tool for shell scripts";

    longDescription = ''
      Yad (yet another dialog) is a GUI dialog tool for shell scripts. It is a
      fork of Zenity with many improvements, such as custom buttons, additional
      dialogs, pop-up menu in notification icon and more.
    '';

    homepage = "https://github.com/v1cont/yad";
    license = lib.licenses.gpl3;
    maintainers = [ ];
    platforms = with lib.platforms; linux;
    mainProgram = "yad";
  };
})
