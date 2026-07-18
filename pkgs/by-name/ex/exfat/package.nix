{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  fuse3,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "exfat";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "relan";
    repo = "exfat";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5m8fiItEOO6piR132Gxq6SHOPN1rAFTuTVE+UI0V00k=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [ fuse3 ];

  meta = {
    description = "Free exFAT file system implementation";
    homepage = "https://github.com/relan/exfat";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ dywedir ];
    platforms = lib.platforms.unix;
  };
})
