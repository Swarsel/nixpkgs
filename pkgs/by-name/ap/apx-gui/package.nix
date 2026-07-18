{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream-glib,
  apx,
  desktop-file-utils,
  gnome-console,
  gobject-introspection,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  python3,
  vte-gtk4,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "apx-gui";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "Vanilla-OS";
    repo = "apx-gui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FE/QoDzpTMez0nQWsIe8HTkwtXBGiQvZKyjfui6sqhY=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    appstream-glib
    desktop-file-utils
    gobject-introspection
    meson
    ninja
    pkg-config
    (python3.withPackages (ps: [
      ps.pygobject3
      ps.pyyaml
      ps.podman
    ]))
    wrapGAppsHook4
  ];

  buildInputs = [
    libadwaita
    vte-gtk4
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : "${
        lib.makeBinPath [
          apx
          gnome-console
        ]
      }"
    )
  '';

  meta = {
    description = "GUI frontend for Apx in GTK 4 and Libadwaita";
    homepage = "https://github.com/Vanilla-OS/apx-gui";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "apx-gui";
  };
})
