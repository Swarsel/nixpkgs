{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "termbox";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "termbox";
    repo = "termbox";
    rev = "v${finalAttrs.version}";
    sha256 = "075swv6ajx8m424dbmgbf6fs6nd5q004gjpvx48gkxmnf9spvykl";
  };

  makeFlags = [ "prefix=${placeholder "out"}" ];

  meta = {
    description = "Library for writing text-based user interfaces";
    homepage = "https://github.com/termbox/termbox#readme";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fgaz ];
    downloadPage = "https://github.com/termbox/termbox/releases";
  };
})
