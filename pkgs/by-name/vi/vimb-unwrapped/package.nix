{
  lib,
  stdenv,
  fetchFromGitHub,
  glib-networking,
  gsettings-desktop-schemas,
  gtk3,
  libsoup_3,
  pkg-config,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vimb";
  version = "3.7.1";

  src = fetchFromGitHub {
    owner = "fanglingsu";
    repo = "vimb";
    tag = finalAttrs.version;
    hash = "sha256-3h4dTjGQ0Ds2BDG0cUmbNvtEmDuizDJ0BYvpCfMz+I0=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    pkg-config
  ];

  buildInputs = [
    gtk3
    libsoup_3
    webkitgtk_4_1
    glib-networking
    gsettings-desktop-schemas
  ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  passthru = {
    inherit gtk3;
    applicationName = "Vimb";
  };

  meta = {
    description = "Vim-like browser";

    longDescription = ''
      A fast and lightweight vim like web browser based on the webkit web
      browser engine and the GTK toolkit. Vimb is modal like the great vim
      editor and also easily configurable during runtime. Vimb is mostly
      keyboard driven and does not detract you from your daily work.
    '';

    homepage = "https://fanglingsu.github.io/vimb/";
    license = lib.licenses.gpl3;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "vimb";
  };
})
