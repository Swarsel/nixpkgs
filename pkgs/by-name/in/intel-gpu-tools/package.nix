{
  lib,
  stdenv,
  fetchFromGitLab,
  # runtime
  alsa-lib,
  # build time
  bison,
  cairo,
  curl,
  docbook_xsl,
  docutils,
  elfutils,
  flex,
  glib,
  gsl,
  gtk-doc,
  json_c,
  kmod,
  libdrm,
  liboping,
  libpciaccess,
  libunwind,
  libx11,
  libxext,
  libxrandr,
  libxv,
  meson,
  ninja,
  openssl,
  peg,
  pkg-config,
  procps,
  python3,
  udev,
  util-macros,
  valgrind,
  xmlrpc_c,
  xorgproto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "intel-gpu-tools";
  version = "2.3";

  src = fetchFromGitLab {
    owner = "drm";
    repo = "igt-gpu-tools";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CkVBImPPM93Q2SVpKzRAREd7cK+SmUgySiuq3LfO2O8=";
    domain = "gitlab.freedesktop.org";
  };

  nativeBuildInputs = [
    bison
    docbook_xsl
    docutils
    flex
    gtk-doc
    meson
    ninja
    pkg-config
    util-macros
  ];

  buildInputs = [
    alsa-lib
    cairo
    curl
    elfutils
    glib
    gsl
    json_c
    kmod
    libdrm
    liboping
    libpciaccess
    libunwind
    libx11
    libxext
    libxrandr
    libxv
    openssl
    peg
    procps
    python3
    udev
    valgrind
    xmlrpc_c
    xorgproto
  ];

  preConfigure = ''
    patchShebangs lib man scripts tests
  '';

  hardeningDisable = [ "bindnow" ];

  meta = {
    description = "Tools for development and testing of the Intel DRM driver";
    homepage = "https://drm.pages.freedesktop.org/igt-gpu-tools/";
    changelog = "https://gitlab.freedesktop.org/drm/igt-gpu-tools/-/blob/v${finalAttrs.version}/NEWS";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      pSub
      ilkecan
    ];

    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];
  };
})
