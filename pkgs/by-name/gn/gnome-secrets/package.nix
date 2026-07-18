{
  lib,
  fetchFromGitLab,
  appstream-glib,
  desktop-file-utils,
  gdk-pixbuf,
  gettext,
  glib,
  gobject-introspection,
  gtk4,
  gtksourceview5,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  opensc,
  pkg-config,
  python3Packages,
  shared-mime-info,
  wrapGAppsHook4,
  xvfb-run,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "gnome-secrets";
  version = "12.3";

  src = fetchFromGitLab {
    owner = "World";
    repo = "secrets";
    tag = finalAttrs.version;
    hash = "sha256-ypkzswfX/qdVtMja2oky8Gein2BO1gzDvjbtcd3Javc=";
    domain = "gitlab.gnome.org";
  };

  postPatch = ''
    substituteInPlace gsecrets/meson.build \
      --replace-fail \
        "join_paths(get_option('prefix'), get_option('libdir'), 'opensc-pkcs11.so')" \
        "'${lib.getLib opensc}/lib/opensc-pkcs11.so'"
  '';

  nativeBuildInputs = [
    meson
    ninja
    gettext
    pkg-config
    wrapGAppsHook4
    desktop-file-utils
    shared-mime-info
    appstream-glib
    gobject-introspection
  ];

  buildInputs = [
    gtk4
    glib
    gdk-pixbuf
    libadwaita
    gtksourceview5
  ];

  doCheck = true;

  nativeCheckInputs = [
    python3Packages.pytest
    xvfb-run
  ];

  checkPhase = ''
    runHook preCheck
    env \
      GTK_A11Y=none \
      PYTHONPATH="$out/${python3Packages.python.sitePackages}:$PYTHONPATH" \
      XDG_DATA_DIRS="$out/share/gsettings-schemas/$name:$XDG_DATA_DIRS" \
      xvfb-run meson test --print-errorlogs
    runHook postCheck
  '';

  dependencies = with python3Packages; [
    pygobject3
    construct
    pyhibp
    pykcs11
    pykeepass
    pyotp
    validators
    yubico
    zxcvbn-rs-py
  ];

  # Prevent double wrapping, let the Python wrapper use the args in preFixup.
  dontWrapGApps = true;
  makeWrapperArgs = [ "\${gappsWrapperArgs[@]}" ];
  pyproject = false;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Password manager for GNOME which makes use of the KeePass v.4 format";
    homepage = "https://gitlab.gnome.org/World/secrets";
    changelog = "https://gitlab.gnome.org/World/secrets/-/releases/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ mvnetbiz ];
    platforms = lib.platforms.linux;
    mainProgram = "secrets";
    teams = [ lib.teams.gnome-circle ];
  };
})
