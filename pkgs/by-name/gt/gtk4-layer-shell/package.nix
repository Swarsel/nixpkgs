{
  lib,
  stdenv,
  fetchFromGitHub,
  docbook-xsl-nons,
  docbook_xml_dtd_43,
  gobject-introspection,
  gtk-doc,
  gtk4,
  meson,
  mesonEmulatorHook,
  ninja,
  pkg-config,
  vala,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gtk4-layer-shell";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "wmww";
    repo = "gtk4-layer-shell";
    rev = "v${finalAttrs.version}";
    hash = "sha256-2OZsLUUsWVk5oh5Y/UFjTqzcM+u2NSPG/YS7uT3iRfc=";
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
    vala
    wayland-scanner
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [ mesonEmulatorHook ];

  buildInputs = [
    gtk4
    wayland
    wayland-protocols
  ];

  mesonFlags = [
    "-Ddocs=true"
    "-Dexamples=true"
  ];

  depsBuildBuild = [
    pkg-config
  ];

  outputBin = "devdoc";

  meta = {
    description = "Library to create panels and other desktop components for Wayland using the Layer Shell protocol and GTK4";
    homepage = "https://github.com/wmww/gtk4-layer-shell";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ donovanglover ];
    platforms = lib.platforms.linux;
    mainProgram = "gtk4-layer-demo";
  };
})
