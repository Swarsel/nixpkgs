{
  lib,
  fetchFromGitHub,
  appstream-glib,
  # build inputs
  atk,
  desktop-file-utils,
  file,
  fluidsynth,
  gdk-pixbuf,
  gettext,
  glib,
  glib-networking,
  gnome-desktop,
  gobject-introspection,
  gst_all_1,
  gtk3,
  libnotify,
  libstrangle,
  mesa-demos,
  meson,
  ninja,
  p7zip,
  pango,
  pciutils,
  pkg-config,
  psmisc,
  pulseaudio,
  python3Packages,
  setxkbmap,
  util-linux,
  vulkan-tools,
  webkitgtk_4_1,
  wrapGAppsHook3,
  xgamma,
  xkbcomp,
  xorg-server,
  # commands that lutris needs
  xrandr,
}:

let
  # See lutris/util/linux.py
  requiredTools = [
    xrandr
    pciutils
    psmisc
    mesa-demos
    vulkan-tools
    pulseaudio
    p7zip
    xgamma
    libstrangle
    fluidsynth
    xorg-server
    setxkbmap
    xkbcomp
    # bypass mount suid wrapper which does not work in fhsenv
    util-linux
  ];
in
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "lutris-unwrapped";
  version = "0.5.22";

  src = fetchFromGitHub {
    owner = "lutris";
    repo = "lutris";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4mNknvfJQJEPZjQoNdKLQcW4CI93D6BUDPj8LtD940A=";
  };

  postPatch = ''
    substituteInPlace lutris/util/magic.py \
      --replace '"libmagic.so.1"' "'${lib.getLib file}/lib/libmagic.so.1'"
  '';

  nativeBuildInputs = [
    appstream-glib
    desktop-file-utils
    gettext
    glib
    gobject-introspection
    meson
    ninja
    wrapGAppsHook3
    pkg-config
  ];

  buildInputs = [
    atk
    gdk-pixbuf
    glib-networking
    gnome-desktop
    gtk3
    libnotify
    pango
    webkitgtk_4_1
  ]
  ++ (with gst_all_1; [
    gst-libav
    gst-plugins-bad
    gst-plugins-base
    gst-plugins-good
    gst-plugins-ugly
    gstreamer
  ]);

  # See `install_requires` in https://github.com/lutris/lutris/blob/master/setup.py
  dependencies = with python3Packages; [
    certifi
    dbus-python
    distro
    evdev
    lxml
    pillow
    pygobject3
    pypresence
    pyyaml
    requests
    protobuf
    moddb
  ];

  # avoid double wrapping
  dontWrapGApps = true;

  makeWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath requiredTools}"
    "--prefix APPIMAGE_EXTRACT_AND_RUN : 1"
    "\${gappsWrapperArgs[@]}"
  ];

  pyproject = false;

  meta = {
    description = "Open Source gaming platform for GNU/Linux";
    homepage = "https://lutris.net";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ rapiteanu ];
    platforms = lib.platforms.linux;
    mainProgram = "lutris";
  };
})
