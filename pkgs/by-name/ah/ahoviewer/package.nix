{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  config,
  curl,
  glibmm,
  gst_all_1,
  gtkmm2,
  libconfig,
  librsvg,
  libsecret,
  libxml2,
  libzip,
  makeWrapper,
  pkg-config,
  unrar,
  useUnrar ? config.ahoviewer.useUnrar or false,
}:

assert useUnrar -> unrar != null;

stdenv.mkDerivation (finalAttrs: {
  pname = "ahoviewer";
  version = "1.6.5";

  src = fetchFromGitHub {
    owner = "ahodesuka";
    repo = "ahoviewer";
    tag = finalAttrs.version;
    sha256 = "1avdl4qcpznvf3s2id5qi1vnzy4wgh6vxpnrz777a1s4iydxpcd8";
  };

  postPatch = "patchShebangs version.sh";

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    glibmm
    libconfig
    gtkmm2
    glibmm
    libxml2
    libsecret
    curl
    libzip
    librsvg
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-good
    gst_all_1.gst-libav
    gst_all_1.gst-plugins-base
  ]
  ++ lib.optional useUnrar unrar;

  env.NIX_LDFLAGS = "-lpthread";

  postInstall = ''
    wrapProgram $out/bin/ahoviewer \
    --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0" \
    --set GDK_PIXBUF_MODULE_FILE "$GDK_PIXBUF_MODULE_FILE"
  '';

  enableParallelBuilding = true;

  meta = {
    description = "GTK2 image viewer, manga reader, and booru browser";
    homepage = "https://github.com/ahodesuka/ahoviewer";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xzfc ];
    # Unintentionally not working on Darwin:
    # https://github.com/ahodesuka/ahoviewer/issues/62
    platforms = lib.platforms.linux;
    mainProgram = "ahoviewer";
  };
})
