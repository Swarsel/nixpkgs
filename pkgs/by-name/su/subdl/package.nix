{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
}:

stdenv.mkDerivation {
  pname = "subdl";
  version = "0-unstable-2017-11-06";

  src = fetchFromGitHub {
    owner = "alexanderwink";
    repo = "subdl";
    rev = "4cf5789b11f0ff3f863b704b336190bf968cd471";
    sha256 = "0kmk5ck1j49q4ww0lvas2767kwnzhkq0vdwkmjypdx5zkxz73fn8";
  };

  buildInputs = [ python3 ];

  installPhase = ''
    install -vD subdl $out/bin/subdl
  '';

  meta = {
    description = "Command-line tool to download subtitles from opensubtitles.org";
    homepage = "https://github.com/alexanderwink/subdl";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.exfalso ];
    platforms = lib.platforms.all;
    mainProgram = "subdl";
  };
}
