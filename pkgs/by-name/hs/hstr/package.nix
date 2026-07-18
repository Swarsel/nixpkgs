{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gettext,
  ncurses,
  pkg-config,
  readline,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hstr";
  version = "3.2";

  src = fetchFromGitHub {
    owner = "dvorka-oss";
    repo = "hstr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-c+YUpry96OGJ7nmBw180W2r0z4EBd2Cl3SyOQrNxP+o=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    readline
    ncurses
    gettext
  ];

  configureFlags = [ "--prefix=$(out)" ];

  meta = {
    description = "Shell history suggest box - easily view, navigate, search and use your command history";
    homepage = "https://github.com/dvorka-oss/hstr";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.matthiasbeyer ];
    platforms = with lib.platforms; linux ++ darwin;
  };

})
