{
  lib,
  stdenv,
  fetchFromGitea,
  glib,
  gobject-introspection,
  gtk3,
  meson,
  ninja,
  pkg-config,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libgflow";
  version = "1.0.4";

  src = fetchFromGitea {
    owner = "grindhold";
    repo = "libgtkflow";
    rev = "gflow_${finalAttrs.version}";
    hash = "sha256-JoVq7U5JQ3pRxptR7igWFw7lcBTsgr3aVXxayLqhyFo=";
    domain = "notabug.org";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  nativeBuildInputs = [
    vala
    meson
    ninja
    pkg-config
    gobject-introspection
  ];

  buildInputs = [
    gtk3
    glib
  ];

  mesonFlags = [
    "-Denable_valadoc=true"
    "-Denable_gtk3=false"
    "-Denable_gtk4=false"
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
