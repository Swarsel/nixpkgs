{
  lib,
  stdenv,
  fetchFromGitHub,
  docbook-xsl-nons,
  docbook_xml_dtd_43,
  gobject-introspection,
  gtk-doc,
  gtk3,
  meson,
  ninja,
  pkg-config,
  vala,
  wayland,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gtk-layer-shell";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "wmww";
    repo = "gtk-layer-shell";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Qhbk5g3cYaE6qH/V4t0OMU/PsW233G53v8Ft0ceYfCI=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    gtk-doc
    docbook-xsl-nons
    docbook_xml_dtd_43
    wayland-scanner
    vala
    wayland-scanner
  ];

  buildInputs = [
    wayland
    gtk3
  ];

  mesonFlags = [
    "-Ddocs=true"
    "-Dexamples=true"
  ];

  depsBuildBuild = [
    pkg-config
  ];

  outputBin = "devdoc"; # for demo

  meta = {
    description = "Library to create panels and other desktop components for Wayland using the Layer Shell protocol";
    homepage = "https://github.com/wmww/gtk-layer-shell";
    license = lib.licenses.lgpl3Plus;

    maintainers = with lib.maintainers; [
      eonpatapon
      donovanglover
    ];

    platforms = lib.platforms.linux;
    mainProgram = "gtk-layer-demo";
  };
})
