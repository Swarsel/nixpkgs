{
  lib,
  fetchFromGitHub,
  dbus,
  dconf,
  glib,
  gobject-introspection,
  gsettings-desktop-schemas,
  gtk3,
  nautilus,
  nautilus-python,
  pkg-config,
  python3,
  wrapGAppsHook3,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "nautilus-open-any-terminal";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "Stunkymonkey";
    repo = "nautilus-open-any-terminal";
    tag = version;
    hash = "sha256-SqkvQZZXSFC5WRjOn/6uPx+bDWFCz1g6OtCatUM9+0U=";
  };

  patches = [ ./hardcode-gsettings.patch ];

  postPatch = ''
    substituteInPlace nautilus_open_any_terminal/nautilus_open_any_terminal.py \
      --subst-var-by gsettings_path ${glib.makeSchemaPath "$out" "$name"}
  '';

  nativeBuildInputs = [
    glib
    gobject-introspection
    pkg-config
    wrapGAppsHook3
    python3.pkgs.setuptools-scm
  ];

  buildInputs = [
    dbus
    dconf
    nautilus
    nautilus-python
    gsettings-desktop-schemas
    gtk3
    python3.pkgs.pygobject3
  ];

  postInstall = ''
    glib-compile-schemas "$out/share/glib-2.0/schemas"
  '';

  pyproject = true;

  meta = {
    description = "Extension for nautilus, which adds an context-entry for opening other terminal-emulators then `gnome-terminal`";
    homepage = "https://github.com/Stunkymonkey/nautilus-open-any-terminal";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ stunkymonkey ];
    platforms = lib.platforms.linux;
  };
}
