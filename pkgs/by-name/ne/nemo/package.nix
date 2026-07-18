{
  lib,
  stdenv,
  fetchFromGitHub,
  cinnamon-desktop,
  cinnamon-translations,
  exempi,
  glib,
  gobject-introspection,
  gtk3,
  gvfs,
  intltool,
  json-glib,
  libexif,
  libgsf,
  libxmlb,
  meson,
  ninja,
  pkg-config,
  python3,
  shared-mime-info,
  wrapGAppsHook3,
  xapp,
  xapp-symbolic-icons,
  xdg-user-dirs,
}:

let
  # For action-layout-editor.
  pythonEnv = python3.withPackages (
    pp: with pp; [
      pycairo
      pygobject3
      python-xapp
    ]
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "nemo";
  version = "6.6.4";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "nemo";
    rev = finalAttrs.version;
    hash = "sha256-HYrpq22rWScdweDQQlrQbOShYFH4FjZWQKBnvKIsOAI=";
  };

  outputs = [
    "out"
    "dev"
    "man"
  ];

  patches = [
    # Load extensions from NEMO_EXTENSION_DIR environment variable
    # https://github.com/NixOS/nixpkgs/issues/78327
    ./load-extensions-from-env.patch
  ];

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
    wrapGAppsHook3
    intltool
    shared-mime-info
    gobject-introspection
  ];

  buildInputs = [
    glib
    gtk3
    cinnamon-desktop
    libxmlb # action-layout-editor
    pythonEnv
    xapp
    libexif
    exempi
    gvfs
    libgsf
    json-glib
  ];

  mesonFlags = [
    # use locales from cinnamon-translations
    "--localedir=${cinnamon-translations}/share/locale"
  ];

  preFixup = ''
    gappsWrapperArgs+=(
       --prefix XDG_DATA_DIRS : "${
         lib.makeSearchPath "share" [
           # For non-fd.o icons.
           xapp
           xapp-symbolic-icons
         ]
       }"
       --prefix PATH : "${
         lib.makeBinPath [
           # For xdg-user-dirs-update.
           xdg-user-dirs
         ]
       }"
    )
  '';

  # Taken from libnemo-extension.pc.
  passthru.extensiondir = "lib/nemo/extensions-3.0";

  meta = {
    description = "File browser for Cinnamon";
    homepage = "https://github.com/linuxmint/nemo";

    license = [
      lib.licenses.gpl2
      lib.licenses.lgpl2
    ];

    platforms = lib.platforms.linux;
    mainProgram = "nemo";
    teams = [ lib.teams.cinnamon ];
  };
})
