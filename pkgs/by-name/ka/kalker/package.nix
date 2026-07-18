{
  lib,
  fetchFromGitHub,
  gmp,
  libmpc,
  mpfr,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kalker";
  version = "2.2.2";

  src = fetchFromGitHub {
    owner = "PaddiM8";
    repo = "kalker";
    rev = "v${finalAttrs.version}";
    hash = "sha256-jpWGR69Xxiv8yjQ5I7TTxOS8Hotsyxt1Dr676zWjvAE=";
  };

  outputs = [
    "out"
    "lib"
  ];

  buildInputs = [
    gmp
    mpfr
    libmpc
  ];

  cargoHash = "sha256-LEP2ebthwtpPSRmJt0BW/T/lB6EE+tylyVv+PDt8UoQ=";
  env.CARGO_FEATURE_USE_SYSTEM_LIBS = "1";

  postInstall = ''
    moveToOutput "lib" "$lib"
  '';

  meta = {
    description = "Command line calculator";

    longDescription = ''
      A command line calculator that supports math-like syntax with user-defined
      variables, functions, derivation, integration, and complex numbers
    '';

    homepage = "https://kalker.strct.net";
    changelog = "https://github.com/PaddiM8/kalker/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      lovesegfault
    ];

    mainProgram = "kalker";
  };
})
