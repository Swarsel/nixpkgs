{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  gitUpdater,
  libpng,
  pkg-config,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "aribb24";
  version = "1.0.4";

  src = fetchFromGitLab {
    owner = "jeeb";
    repo = "aribb24";
    rev = "v${finalAttrs.version}";
    hash = "sha256-hq3LnLACZfV+E76ZDEHGlN51fS6AqFnNReE3JlWcv9M=";
    domain = "code.videolan.org";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libpng
  ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
    updateScript = gitUpdater { rev-prefix = "v"; };
  };

  meta = {
    description = "Library for ARIB STD-B24, decoding JIS 8 bit characters and parsing MPEG-TS stream";
    homepage = "https://code.videolan.org/jeeb/aribb24/";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ jopejoe1 ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "aribb24" ];
  };
})
