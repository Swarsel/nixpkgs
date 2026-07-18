{
  lib,
  stdenv,
  fetchFromGitLab,
  appstream,
  appstream-glib,
  blueprint-compiler,
  desktop-file-utils,
  gettext,
  glib,
  gobject-introspection,
  gtk4,
  libadwaita,
  librsvg,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "eartag";
  version = "1.0.2";

  src = fetchFromGitLab {
    owner = "World";
    repo = "eartag";
    rev = finalAttrs.version;
    hash = "sha256-Iwfk0SqxYF2bzkKZNqGonJh8MQ2c+K1wN0o4GECR/Rw=";
    domain = "gitlab.gnome.org";
  };

  postPatch = ''
    chmod +x ./build-aux/meson/postinstall.py
    patchShebangs ./build-aux/meson/postinstall.py
    substituteInPlace ./build-aux/meson/postinstall.py \
      --replace "gtk-update-icon-cache" "gtk4-update-icon-cache"
  '';

  nativeBuildInputs = [
    meson
    ninja
    glib
    desktop-file-utils
    appstream
    appstream-glib
    pkg-config
    gettext
    gobject-introspection
    wrapGAppsHook4
    blueprint-compiler
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin gtk4; # for gtk4-update-icon-cache

  buildInputs = [
    librsvg
    libadwaita
  ];

  propagatedBuildInputs = with python3Packages; [
    aiofiles
    aiohttp
    pygobject3
    eyed3
    pillow
    mutagen
    pytaglib
    python-magic
    pyacoustid
    xxhash
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dontWrapGApps = true;
  pyproject = false;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Simple music tag editor";
    homepage = "https://gitlab.gnome.org/World/eartag";
    changelog = "https://gitlab.gnome.org/World/eartag/-/releases/${finalAttrs.version}";
    # This seems to be using ICU license but we're flagging it to MIT license
    # since ICU license is a modified version of MIT and to prevent it from
    # being incorrectly identified as unfree software.
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "eartag";
    teams = [ lib.teams.gnome-circle ];
  };
})
