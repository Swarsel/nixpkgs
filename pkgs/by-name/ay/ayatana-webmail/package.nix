{
  lib,
  fetchFromGitHub,
  gdk-pixbuf,
  gettext,
  glib,
  gobject-introspection,
  gsettings-desktop-schemas,
  gtk3,
  # BTW libappindicator is also supported, but upstream recommends their
  # implementation, see:
  # https://github.com/AyatanaIndicators/ayatana-webmail/issues/24#issuecomment-1050352862
  libayatana-appindicator,
  libcanberra-gtk3,
  libnotify,
  python3Packages,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "ayatana-webmail";
  version = "26.6.13";

  src = fetchFromGitHub {
    owner = "AyatanaIndicators";
    repo = "ayatana-webmail";
    tag = finalAttrs.version;
    hash = "sha256-AVH4SQ2yoC2SXuKt8MJVGAgB32cTOD7mCVxcBZn/PPM=";
  };

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
    glib # For compiling gsettings-schemas
  ];

  buildInputs = [
    gtk3
    gdk-pixbuf
    glib
    libnotify
    gettext
    libayatana-appindicator
    gsettings-desktop-schemas
  ];

  postConfigure = ''
    # Fix fhs paths
    substituteInPlace \
      ayatanawebmail/accounts.py \
      ayatanawebmail/actions.py \
      ayatanawebmail/dialog.py \
      --replace-fail /usr/share $out/share
  '';

  # No tests, and they cause a failure
  doCheck = false;

  postInstall = ''
    # Fix fhs paths
    mv $out/${python3Packages.python.sitePackages}/etc $out
    mv $out/${python3Packages.python.sitePackages}/usr/{bin,share} $out/
    rmdir $out/${python3Packages.python.sitePackages}/usr
    # Compile gsettings desktop schemas
    glib-compile-schemas $out/share/glib-2.0/schemas
  '';

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
    makeWrapperArgs+=(--prefix PATH : ${lib.makeBinPath [ libcanberra-gtk3 ]})
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    urllib3
    babel
    psutil
    secretstorage
    polib
    pygobject3
    dbus-python
  ];

  # See https://nixos.org/nixpkgs/manual/#ssec-gnome-common-issues-double-wrapped
  dontWrapGApps = true;
  pyproject = true;

  meta = {
    description = "Webmail notifications and actions for any desktop";
    homepage = "https://github.com/AyatanaIndicators/ayatana-webmail";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ doronbehar ];
    platforms = lib.platforms.linux;
  };
})
