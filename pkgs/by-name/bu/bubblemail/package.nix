{
  lib,
  fetchFromGitLab,
  bash,
  folks,
  gdk-pixbuf,
  gettext,
  glib,
  gnome-online-accounts,
  gobject-introspection,
  gsettings-desktop-schemas,
  gst_all_1,
  gtk3,
  libnotify,
  libsecret,
  python3Packages,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "bubblemail";
  version = "1.9";

  src = fetchFromGitLab {
    owner = "razer";
    repo = "bubblemail";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-eXEFBLo7CbLRlnI2nr7qWAdLUKe6PLQJ78Ho8MP9ShY=";
    domain = "framagit.org";
  };

  nativeBuildInputs = [
    gettext
    wrapGAppsHook3
    python3Packages.pillow
    # For setup-hook
    gobject-introspection
  ];

  buildInputs = [
    gtk3
    gdk-pixbuf
    glib
    libnotify
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    libsecret
    gnome-online-accounts
    folks
    bash
  ];

  propagatedBuildInputs = with python3Packages; [
    gsettings-desktop-schemas
    pygobject3
    dbus-python
    pyxdg
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  # See https://nixos.org/nixpkgs/manual/#ssec-gnome-common-issues-double-wrapped
  dontWrapGApps = true;
  pyproject = true;

  meta = {
    description = "Extensible mail notification service";
    homepage = "http://bubblemail.free.fr/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ doronbehar ];
    platforms = lib.platforms.linux;
  };
})
