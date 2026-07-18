{
  lib,
  stdenv,
  blueprint-compiler,
  desktop-file-utils,
  fetchFromSourcehut,
  gobject-introspection,
  gtk4,
  libadwaita,
  libnotify,
  meson,
  ninja,
  pkg-config,
  python3,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "confy";
  version = "0.9.0";

  src = fetchFromSourcehut {
    owner = "~fabrixxm";
    repo = "confy";
    rev = finalAttrs.version;
    hash = "sha256-dcQ0ynEqrrGjAqQoWXtLMpvBVzpilXGpGWVNaVHp3CY=";
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
    libnotify
    (python3.withPackages (
      ps: with ps; [
        icalendar
        pygobject3
      ]
    ))
  ];

  meta = {
    description = "Conferences schedule viewer";
    homepage = "https://confy.kirgroup.net/";
    changelog = "https://git.sr.ht/~fabrixxm/confy/refs/${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ michaelgrahamevans ];
    mainProgram = "confy";
  };
})
