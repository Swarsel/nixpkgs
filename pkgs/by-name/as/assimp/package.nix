{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nix-update-script,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "assimp";
  version = "6.0.5";

  src = fetchFromGitHub {
    owner = "assimp";
    repo = "assimp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QWBi1pl5C76UtPhB6SmFipm9oEdnfhELMT3MqfV6oxg=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
  ];

  postPatch = ''
    # nix build sandbox does not set /var/tmp up:
    #   https://github.com/assimp/assimp/issues/6270
    substituteInPlace test/unit/UnitTestFileGenerator.h \
      --replace-fail 'define TMP_PATH "/var/tmp/"' 'define TMP_PATH "/tmp/"'
  '';

  strictDeps = true;
  nativeBuildInputs = [ cmake ];

  buildInputs = [
    zlib
  ];

  cmakeFlags = [
    (lib.cmakeBool "ASSIMP_BUILD_ASSIMP_TOOLS" true)
    (lib.cmakeBool "ASSIMP_BUILD_TESTS" finalAttrs.finalPackage.doCheck)
  ];

  # Some matrix tests fail on non-86_64-linux:
  # https://github.com/assimp/assimp/issues/6246
  # https://github.com/assimp/assimp/issues/6247
  # On Darwin, the bundled googletest is not compatible with Clang 21.
  #  contrib/googletest/googletest/include/gtest/gtest-printers.h:498:35:
  #  error: implicit conversion from 'char16_t' to 'char32_t' may change the meaning of the represented code unit
  #  [-Werror,-Wcharacter-conversion]
  doCheck = stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isx86_64;

  checkPhase = ''
    runHook preCheck
    bin/unit
    runHook postCheck
  '';

  enableParallelBuilding = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Library to import various 3D model formats";
    homepage = "https://www.assimp.org/";
    changelog = "https://github.com/assimp/assimp/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "assimp";
  };
})
