{
  lib,
  stdenv,
  fetchFromGitHub,
  cimg,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "imgcat";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "eddieantonio";
    repo = "imgcat";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-miFjlahTI0GDpgsjnA/K1R4R5654M8AoK78CycoLTqA=";
  };

  buildInputs = [
    ncurses
    cimg
  ];

  makeFlags = [ "PREFIX=$(out)" ];
  env.NIX_CFLAGS_COMPILE = "-Wno-error";

  preConfigure = ''
    sed -i -e "s|-ltermcap|-L ${ncurses}/lib -lncurses|" Makefile
  '';

  meta = {
    description = "It's like cat, but for images";
    homepage = "https://github.com/eddieantonio/imgcat";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ jwiegley ];
    platforms = lib.platforms.unix;
    mainProgram = "imgcat";
  };
})
