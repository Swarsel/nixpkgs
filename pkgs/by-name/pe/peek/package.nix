{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream-glib,
  cairo,
  desktop-file-utils,
  fetchpatch,
  ffmpeg-full,
  gettext,
  gifski,
  glib,
  gsettings-desktop-schemas,
  gst_all_1,
  gtk3,
  keybinder3,
  libxml2,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3,
  txt2man,
  vala,
  which,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "peek";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "phw";
    repo = "peek";
    rev = finalAttrs.version;
    sha256 = "1xwlfizga6hvjqq127py8vabaphsny928ar7mwqj9cyqfl6fx41x";
  };

  patches = [
    # Fix compatibility with GNOME Shell ≥ 40.
    # https://github.com/phw/peek/pull/910
    (fetchpatch {
      sha256 = "xxJ+r5uRk93MEzWTFla88ewZsnUl3+YKTenzDygtKP0=";
      url = "https://github.com/phw/peek/commit/008d15316ab5428363c512b263ca8138cb8f52ba.patch";
    })
  ];

  postPatch = ''
    patchShebangs build-aux/meson/postinstall.py data/man/build_man.sh
  '';

  nativeBuildInputs = [
    appstream-glib
    desktop-file-utils
    gettext
    meson
    ninja
    libxml2
    pkg-config
    txt2man
    python3
    vala
    wrapGAppsHook3
  ];

  buildInputs = [
    cairo
    glib
    gsettings-desktop-schemas
    gtk3
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-ugly
    keybinder3
  ];

  preFixup = ''
    gappsWrapperArgs+=(--prefix PATH : ${
      lib.makeBinPath [
        which
        ffmpeg-full
        gifski
      ]
    })
  '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Simple animated GIF screen recorder with an easy to use interface";
    homepage = "https://github.com/phw/peek";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ puffnfresh ];
    platforms = lib.platforms.linux;
    mainProgram = "peek";
  };
})
