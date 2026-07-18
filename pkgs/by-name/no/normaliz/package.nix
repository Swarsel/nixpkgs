{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  flint,
  gmpxx,
  nauty,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "normaliz";
  version = "3.11.0";

  src = fetchFromGitHub {
    owner = "normaliz";
    repo = "normaliz";
    rev = "v${finalAttrs.version}";
    hash = "sha256-O8zUhuR+e9yNxj9jC2xK7UZ2aUHoEWjwxn3XxTyP8hQ=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
  ];

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    gmpxx
    flint
    nauty
  ];

  meta = {
    description = "Open source tool for computations in affine monoids, vector configurations, lattice polytopes, and rational cones";
    homepage = "https://www.normaliz.uni-osnabrueck.de/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ yannickulrich ];
    platforms = with lib.platforms; unix ++ windows;
    mainProgram = "normaliz";
  };
})
