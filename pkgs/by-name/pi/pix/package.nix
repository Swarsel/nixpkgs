{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  brasero,
  colord,
  desktop-file-utils,
  exiv2,
  flex,
  glib,
  gsettings-desktop-schemas,
  gst_all_1,
  gtk3,
  itstool,
  lcms2,
  libheif,
  libjpeg,
  libjxl,
  libraw,
  librsvg,
  libsecret,
  libtiff,
  libwebp,
  libx11,
  meson,
  ninja,
  pkg-config,
  python3,
  shared-mime-info,
  wrapGAppsHook3,
  xapp,
  xapp-symbolic-icons,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pix";
  version = "3.4.10";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "pix";
    rev = finalAttrs.version;
    hash = "sha256-IrRE2Bv2+DZMLI48at7npcAd3TSJRuZNzU/YbNK8x3k=";
  };

  postPatch = ''
    chmod +x pix/make-pix-h.py

    patchShebangs data/gschemas/make-enums.py \
      pix/make-pix-h.py \
      postinstall.py \
      pix/make-authors-tab.py
  '';

  nativeBuildInputs = [
    bison
    desktop-file-utils
    flex
    itstool
    meson
    ninja
    pkg-config
    python3
    wrapGAppsHook3
  ];

  buildInputs = [
    brasero
    colord
    exiv2
    glib
    gsettings-desktop-schemas
    gst_all_1.gst-plugins-base
    (gst_all_1.gst-plugins-good.override { gtkSupport = true; })
    gst_all_1.gst-libav
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gtk3
    lcms2
    libheif
    libjpeg
    libjxl
    libraw
    librsvg
    libsecret
    libtiff
    libwebp
    libx11
    xapp
  ];

  # Avoid direct dependency on webkit2gtk-4.0
  # https://fedoraproject.org/wiki/Changes/Remove_webkit2gtk-4.0_API_Version
  mesonFlags = [ "-Dwebservices=false" ];

  preFixup = ''
    gappsWrapperArgs+=(--prefix XDG_DATA_DIRS : "${
      lib.makeSearchPath "share" [
        shared-mime-info
        xapp-symbolic-icons
      ]
    }")
  '';

  meta = {
    description = "Generic image viewer from Linux Mint";
    homepage = "https://github.com/linuxmint/pix";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
    mainProgram = "pix";
    teams = [ lib.teams.cinnamon ];
  };
})
