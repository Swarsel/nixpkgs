{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  glib-networking,
  libhandy,
  libisocodes,
  libxml2,
  libzim-glib,
  meson,
  ninja,
  pkg-config,
  sqlite,
  tinysparql,
  vala,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "web-archives";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "birros";
    repo = "web-archives";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aP42WiSmpkAw7FtxUftIsHKDztt60xKcL8Zq2iTSRn8=";
  };

  postPatch = ''
    substituteInPlace meson.build \
      --replace-fail \
        "'make', '-C', 'build-aux/darkreader'" \
        "'cp', '${finalAttrs.web-archive-darkreader}', 'build-aux/darkreader/web-archives-darkreader.js'"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    vala
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    libzim-glib
    sqlite
    webkitgtk_4_1
    tinysparql
    libxml2
    libisocodes
    libhandy
    glib-networking
  ];

  web-archive-darkreader = fetchurl {
    hash = "sha256-juhAqs2eCYZKerLnX3NvaW3NS0uOhqB7pyf/PRDvMqE=";
    # This is the same with build-aux/darkreader/Makefile
    url = "https://github.com/birros/web-archives-darkreader/releases/download/v0.0.1/web-archives-darkreader_v0.0.1.js";
  };

  passthru = {
    inherit (finalAttrs) web-archive-darkreader;
  };

  meta = {
    description = "Web archives reader offering the ability to browse offline millions of articles";
    homepage = "https://github.com/birros/web-archives";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.unix;
    mainProgram = "web-archives";
  };
})
