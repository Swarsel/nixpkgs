{
  lib,
  fetchurl,
  autoreconfHook,
  bison,
  flex,
  gccStdenv,
  gmp,
}:

gccStdenv.mkDerivation {
  pname = "veriT";
  version = "2021.06.2";

  src = fetchurl {
    url = "https://verit.loria.fr/download/2021.06.2/verit-2021.06.2-rmx.tar.gz";
    sha256 = "1yjvvxnsix0rhilc81ycx1s85dymq366c6zh1hwwd8qxp7k1zca2";
  };

  nativeBuildInputs = [
    autoreconfHook
    flex
    bison
  ];

  buildInputs = [ gmp ];
  makeFlags = [ "LEX=${flex}/bin/flex" ];

  preInstall = ''
    mkdir -p $out/bin
  '';

  # --disable-static actually enables static linking here...
  dontDisableStatic = true;

  meta = {
    description = "Open, trustable and efficient SMT-solver";
    homepage = "https://verit.loria.fr/";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
}
