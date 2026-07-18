{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libdivsufsort";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "y-256";
    repo = "libdivsufsort";
    rev = "${finalAttrs.version}";
    hash = "sha256-4p+L1bq9SBgWSHXx+WYWAe60V2g1AN+zlJvC+F367Tk=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DBUILD_DIVSUFSORT64=YES"
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.10"
  ];

  meta = {
    description = "Library to construct the suffix array and the BW transformed string";
    homepage = "https://github.com/y-256/libdivsufsort";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
})
