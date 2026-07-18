{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
}:

stdenv.mkDerivation {
  pname = "cudd";
  version = "3.0.0";

  src = fetchurl {
    url = "https://davidkebo.com/source/cudd_versions/cudd-3.0.0.tar.gz";
    sha256 = "0sgbgv7ljfr0lwwwrb9wsnav7mw7jmr3k8mygwza15icass6dsdq";
  };

  patches = [
    ./cudd.patch
  ];

  nativeBuildInputs = [ autoreconfHook ];

  configureFlags = [
    "--enable-dddmp"
    "--enable-obj"
  ];

  meta = {
    description = "Binary Decision Diagram (BDD) library";
    homepage = "https://davidkebo.com/cudd";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ chessai ];
    platforms = lib.platforms.all;
  };
}
