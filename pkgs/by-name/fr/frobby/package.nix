{
  lib,
  stdenv,
  fetchFromGitHub,
  fixDarwinDylibNames,
  gmp,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "frobby";
  version = "0.9.9";

  src = fetchFromGitHub {
    owner = "Macaulay2";
    repo = "frobby";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LndLfORnypLqFgNMPEJ8jc2Fa2xWWgYS9rZ7gGFbwwo=";
  };

  strictDeps = true;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    fixDarwinDylibNames
  ];

  buildInputs = [
    gmp
  ];

  makeFlags = [
    "MODE=shared"
    "PREFIX=${placeholder "out"}"
  ];

  buildFlags = [
    "all"
    "library"
  ];

  doCheck = true;

  preCheck = ''
    patchShebangs --build ./test
  '';

  __structuredAttrs = true;
  checkTarget = "test";
  enableParallelBuilding = true;

  meta = {
    description = "Software system and project for computations with monomial ideals";

    longDescription = ''
      Current functionality includes Euler characteristic, Hilbert series,
      maximal standard monomials, combinatorial optimization on monomial
      ideals, primary decomposition, irreducible decomposition, Alexander dual,
      associated primes, minimization and intersection of monomial ideals as
      well as the computation of Frobenius problems (using 4ti2) with very
      large numbers. Frobby is also able to translate between formats that can
      be used with several different computer systems, such as Macaulay2,
      Monos, 4ti2, CoCoA4 and Singular. Thus Frobby can be used with any of
      those systems.
    '';

    homepage = "https://github.com/Macaulay2/frobby";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ coolcuber ];
    platforms = lib.platforms.unix;
    mainProgram = "frobby";
  };
})
