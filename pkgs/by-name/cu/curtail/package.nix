{
  lib,
  fetchFromGitHub,
  appstream-glib,
  blueprint-compiler,
  desktop-file-utils,
  gettext,
  gobject-introspection,
  gtk4,
  jpegoptim,
  libadwaita,
  libwebp,
  meson,
  ninja,
  nix-update-script,
  optipng,
  oxipng,
  pkg-config,
  pngquant,
  python3,
  wrapGAppsHook4,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "curtail";
  version = "1.16.1";

  src = fetchFromGitHub {
    owner = "Huluti";
    repo = "Curtail";
    tag = finalAttrs.version;
    hash = "sha256-vegtuuGyjfr0vJgaGLTkws/BysxHeVod/C9bz8lnJpo=";
  };

  nativeBuildInputs = [
    wrapGAppsHook4
    appstream-glib
    blueprint-compiler
    desktop-file-utils
    gettext
    gtk4
    libadwaita
    meson
    ninja
    pkg-config
    gobject-introspection
  ];

  buildInputs = [
    appstream-glib
    gettext
    gtk4
    libadwaita
  ];

  propagatedBuildInputs = [
    python3.pkgs.pygobject3
  ];

  preInstall = ''
    patchShebangs ../build-aux/meson/postinstall.py
  '';

  preFixup = ''
    makeWrapperArgs+=(
      "''${gappsWrapperArgs[@]}"
      "--prefix" "PATH" ":" "${
        lib.makeBinPath [
          jpegoptim
          libwebp
          optipng
          pngquant
          oxipng
        ]
      }"
    )
  '';

  dontWrapGApps = true;
  pyproject = false;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Simple & useful image compressor";
    homepage = "https://github.com/Huluti/Curtail";
    license = lib.licenses.gpl3Only;
    mainProgram = "curtail";
    teams = [ lib.teams.gnome-circle ];
  };
})
