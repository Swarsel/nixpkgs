{
  lib,
  stdenv,
  fetchFromGitHub,
  adwaita-icon-theme,
  appstream-glib,
  glib,
  gobject-introspection,
  gst_all_1,
  gtk3,
  libnotify,
  libsecret,
  meson,
  ninja,
  pkg-config,
  python3Packages,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "pithos";
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "pithos";
    repo = "pithos";
    tag = finalAttrs.version;
    hash = "sha256-3j6IoMi30BQ8WHK4BxbsW+/3XZx7rBFd47EBENa2GiQ=";
  };

  postPatch = ''
    chmod +x meson_post_install.py
    patchShebangs meson_post_install.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    appstream-glib
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    gtk3
    libnotify
    libsecret
    glib
  ]
  ++ (with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-ugly
    gst-plugins-bad
  ]);

  propagatedBuildInputs = [
    adwaita-icon-theme
  ]
  ++ (with python3Packages; [
    pygobject3
    pylast
  ]);

  pyproject = false;

  meta = {
    description = "Pandora Internet Radio player for GNOME";
    homepage = "https://pithos.github.io/";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ obadz ];
    mainProgram = "pithos";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
