{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  ffmpeg-headless,
  ninja,
  nix-update-script,
  testers,
  validatePkgConfig,
  zlib,
  withExamples ? true,
  withTools ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chromaprint";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "acoustid";
    repo = "chromaprint";
    tag = "v${finalAttrs.version}";
    hash = "sha256-G3HIMgbjaAXsC+8nt7mkj58xA62qwA8FC+PfTGblhNg=";
  };

  patches = [
    # fix generated pkg-config files
    (fetchpatch {
      hash = "sha256-drUfAMzTrqqB5UbzOnfPq6XD3HI+3sxyJJSTCa0BmD8=";
      url = "https://github.com/acoustid/chromaprint/commit/782ef6bb5f6498e35f8e275f76998fbd5ffa36d6.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
    ninja
    validatePkgConfig
  ];

  buildInputs = [
    ffmpeg-headless
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    zlib
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_TOOLS" withTools)
  ]
  ++ lib.optionals (!finalAttrs.finalPackage.doCheck) [
    # special-cased to avoid a mass-rebuild: remove from `lib.optionals` as part of next update
    (lib.cmakeBool "BUILD_TESTS" finalAttrs.finalPackage.doCheck)
  ];

  # From some reason it dies at the end...
  doCheck = !stdenv.hostPlatform.isDarwin;

  checkPhase =
    let
      exampleAudio = fetchurl {
        hash = "sha256-I+Ve3/OpL+3Joc928F8M21LhCH2eQfRtaJVx9mNOLW0=";
        name = "Dvorak_Symphony_9_1.mp3";
        url = "https://archive.org/download/Dvorak_Symphony_9/01.Adagio-Allegro_Molto.mp3";
        meta.license = lib.licenses.publicDomain;
      };

      # sha256 because actual output of fpcalc is quite long
      expectedHash = "e2895130bcbe7190184379021daa60c5f5d476da4a2fecb06df7160819662e20";
    in
    ''
      runHook preCheck
      tests/all_tests
      ${lib.optionalString withTools "diff -u <(src/cmd/fpcalc -plain ${exampleAudio} | sha256sum | cut -c-64) <(echo '${expectedHash}')"}
      runHook postCheck
    '';

  # with trivialautovarinit enabled can produce an empty .pc file
  hardeningDisable = [ "trivialautovarinit" ];

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "AcoustID audio fingerprinting library";
    homepage = "https://acoustid.org/chromaprint";
    changelog = "https://github.com/acoustid/chromaprint/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "libchromaprint" ];
  }
  // lib.attrsets.optionalAttrs withTools {
    mainProgram = "fpcalc";
  };
})
