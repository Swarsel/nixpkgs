{
  lib,
  stdenv,
  fetchFromGitea,
  glib,
  gobject-introspection,
  gtk4,
  libgflow,
  meson,
  ninja,
  pkg-config,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libgtkflow4";
  version = "0.2.6";

  src = fetchFromGitea {
    owner = "grindhold";
    repo = "libgtkflow";
    rev = "gtkflow4_${finalAttrs.version}";
    hash = "sha256-JoVq7U5JQ3pRxptR7igWFw7lcBTsgr3aVXxayLqhyFo=";
    domain = "notabug.org";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  postPatch = ''
    rm -r libgflow
  '';

  nativeBuildInputs = [
    vala
    meson
    ninja
    pkg-config
    gobject-introspection
  ];

  buildInputs = [
    gtk4
    glib
    libgflow
  ];

  mesonFlags = [
    "-Denable_valadoc=true"
    "-Denable_gtk3=false"
    "-Denable_gflow=false"
  ];

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc" "$devdoc"
  '';

  outputBin = "devdoc"; # demo app

  meta = {
    description = "Flow graph widget for GTK 3";
    homepage = "https://notabug.org/grindhold/libgtkflow";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ grindhold ];
    platforms = lib.platforms.unix;
  };
})
