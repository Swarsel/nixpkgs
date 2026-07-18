{
  lib,
  stdenv,
  fetchFromGitHub,
  gjs,
  glib,
  typescript,
  unstableGitUpdater,
}:

stdenv.mkDerivation {
  pname = "gnome-shell-extension-pop-shell";
  version = "1.2.0-unstable-2026-03-31";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "shell";
    rev = "7898b65c20735057faf0797f8ed056704ca55f0d";
    hash = "sha256-MmHoOxymo0QSRbRcSbFiv82+QWAwIwXwg/wyGQGVYiI=";
  };

  patches = [
    ./fix-gjs.patch
  ];

  postPatch = ''
    for file in */main.js; do
      substituteInPlace $file --replace "gjs" "${gjs}/bin/gjs"
    done
  '';

  nativeBuildInputs = [
    glib
    gjs
    typescript
  ];

  buildInputs = [ gjs ];
  makeFlags = [ "XDG_DATA_HOME=$(out)/share" ];

  preFixup = ''
    chmod +x $out/share/gnome-shell/extensions/pop-shell@system76.com/*/main.js
  '';

  passthru = {
    extensionPortalSlug = "pop-shell";
    extensionUuid = "pop-shell@system76.com";
    updateScript = unstableGitUpdater { };
  };

  meta = {
    description = "Keyboard-driven layer for GNOME Shell";
    homepage = "https://github.com/pop-os/shell";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.genofire ];
    platforms = lib.platforms.linux;
  };
}
