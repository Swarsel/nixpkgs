{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  dropbox,
  gdk-pixbuf,
  gobject-introspection,
  gtk4,
  nautilus,
  pkg-config,
  python3,
  replaceVars,
}:

let
  version = "2024.04.17";
  dropboxd = "${dropbox}/bin/dropbox";
in
stdenv.mkDerivation {
  inherit version;
  pname = "dropbox-cli";

  src = fetchurl {
    url = "https://linux.dropbox.com/packages/nautilus-dropbox-${version}.tar.bz2";
    hash = "sha256-pqCYzxaqR0f0CBaseT1Z436K47cIDQswYR1sK4Zj8sE=";
  };

  outputs = [
    "out"
    "nautilusExtension"
  ];

  patches = [
    (replaceVars ./fix-cli-paths.patch {
      inherit dropboxd;
      # patch context
      DESKTOP_FILE_DIR = null;
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    gobject-introspection
    gdk-pixbuf
    # only for build, the install command also wants to use GTK through introspection
    # but we are using Nix for installation so we will not need that.
    (python3.withPackages (
      ps: with ps; [
        docutils
        pygobject3
      ]
    ))
  ];

  buildInputs = [
    python3
    gtk4
    nautilus
  ];

  configureFlags = [
    "--with-nautilus-extension-dir=${placeholder "nautilusExtension"}/lib/nautilus/extension-4"
  ];

  makeFlags = [
    "EMBLEM_DIR=${placeholder "nautilusExtension"}/share/nautilus-dropbox/emblems"
  ];

  meta = {
    description = "Command line client for the dropbox daemon";
    homepage = "https://www.dropbox.com";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    # NOTE: Dropbox itself only works on linux, so this is ok.
    platforms = lib.platforms.linux;
    mainProgram = "dropbox";
  };
}
