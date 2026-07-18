{
  lib,
  stdenv,
  fetchurl,
  gitUpdater,
  libx11,
  libxft,
  libxrandr,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bevelbar";
  version = "25.08";

  src = fetchurl {
    url = "https://www.uninformativ.de/git/bevelbar/archives/bevelbar-v${finalAttrs.version}.tar.gz";
    hash = "sha256-XGnvpPNonMVCaMgSqJIiklBMLam/k4XLHUrgnhxoxNI=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    libxft
    libxrandr
  ];

  makeFlags = [ "prefix=$(out)" ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
    url = "https://www.uninformativ.de/git/bevelbar.git/";
  };

  meta = {
    description = "X11 status bar with beveled borders";
    homepage = "https://www.uninformativ.de/git/bevelbar/file/README.html";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      neeasade
    ];

    platforms = lib.platforms.linux;
  };
})
