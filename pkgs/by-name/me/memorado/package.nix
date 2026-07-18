{
  lib,
  stdenv,
  fetchFromGitHub,
  blueprint-compiler,
  desktop-file-utils,
  gobject-introspection,
  gtk4,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  python3,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "memorado";
  version = "0.7";

  src = fetchFromGitHub {
    owner = "wbernard";
    repo = "Memorado";
    tag = finalAttrs.version;
    hash = "sha256-/AGrtVULG8rnfdd3dYqftv2YU+SjhdCQMQSlc8oY8zI=";
  };

  nativeBuildInputs = [
    blueprint-compiler
    desktop-file-utils
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    libadwaita
    (python3.withPackages (
      ps: with ps; [
        pygobject3
      ]
    ))
  ];

  meta = {
    description = "Simple and clean flashcard memorizing app";
    homepage = "https://github.com/wbernard/Memorado";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ onny ];
  };
})
