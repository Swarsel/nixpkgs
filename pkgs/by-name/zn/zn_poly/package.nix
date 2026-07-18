{
  lib,
  stdenv,
  fetchFromGitLab,
  gmp,
  python3,
  tune ? false, # tune to hardware, impure
}:

stdenv.mkDerivation rec {
  pname = "zn_poly";
  version = "0.9.2";

  # sage has picked up the maintenance (bug fixes and building, not development)
  # from the original, now unmaintained project which can be found at
  # http://web.maths.unsw.edu.au/~davidharvey/code/zn_poly/
  src = fetchFromGitLab {
    owner = "sagemath";
    repo = "zn_poly";
    rev = version;
    hash = "sha256-QBItcrrpOGj22/ShTDdfZjm63bGW2xY4c71R1q8abPE=";
  };

  nativeBuildInputs = [
    python3 # needed by ./configure to create the makefile
  ];

  buildInputs = [
    gmp
  ];

  configureFlags = lib.optionals (!tune) [
    "--disable-tuning"
  ];

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];

  # Tuning (either autotuning or with hand-written parameters) is possible
  # but not implemented here.
  # It seems buggy anyways (see homepage).
  buildFlags = [
    "all"
    "${libbasename}${libext}"
  ];

  doCheck = true;

  # `make install` fails to install some header files and the lib file.
  installPhase = ''
    mkdir -p "$out/include/zn_poly"
    mkdir -p "$out/lib"
    cp "${libbasename}"*"${libext}" "$out/lib"
    cp include/*.h "$out/include/zn_poly"
  '';

  # name of library file ("libzn_poly.so")
  libbasename = "libzn_poly";
  libext = stdenv.hostPlatform.extensions.sharedLibrary;

  meta = {
    description = "Polynomial arithmetic over Z/nZ";
    homepage = "https://web.maths.unsw.edu.au/~davidharvey/code/zn_poly/";
    license = with lib.licenses; [ gpl3 ];
    platforms = lib.platforms.unix;
    teams = [ lib.teams.sage ];
  };
}
