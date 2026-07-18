{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  nix-update-script,
  python3,
  testers,
  validatePkgConfig,
  versionCheckHook,
  enableCmdline ? !stdenv.hostPlatform.isNone,
  enableMath ? false,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "jerryscript";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "jerryscript-project";
    repo = "jerryscript";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Evu4qLlwg3Sf9w/ojtZMNxGJEtopHgKnwqlpf115zD4=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
  ];

  patches = [
    # https://github.com/jerryscript-project/jerryscript/issues/5263
    ./fix-gcc15.patch
  ];

  postPatch = ''
    # get rid of bundled CMake toolchain files
    rm cmake/toolchain_*
  '';

  nativeBuildInputs = [
    cmake
    ninja
  ];

  cmakeFlags = [
    (lib.cmakeBool "JERRY_CMDLINE" enableCmdline)
    (lib.cmakeBool "JERRY_MATH" enableMath)
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
  ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-enum-enum-conversion -Wno-enum-float-conversion -Wno-literal-range";
  doCheck = true;

  nativeCheckInputs = [
    python3
  ];

  checkPhase = ''
    runHook preCheck

    pushd ../
    python3 tools/run-tests.py --unittests
    popd

    runHook postCheck
  '';

  # Uses a custom lib variable that ignores what nixpkgs's cmake setupHook specifies.
  postInstall = ''
    mkdir $lib
    mv "$out/lib" "$lib/"
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    validatePkgConfig
    versionCheckHook
  ];

  postInstallCheck = ''
    echo 'print("Hello" + " " + "World!")' | \
    "$out/bin/jerry" - | \
    cmp - <(echo "Hello World!")
  '';

  passthru = {
    tests.pkg-config = testers.hasPkgConfigModules {
      package = finalAttrs.finalPackage;
      versionCheck = true;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Lightweight JavaScript engine for resource-constrained devices";
    homepage = "https://jerryscript.net/";
    changelog = "https://github.com/jerryscript-project/jerryscript/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      wishstudio
    ];

    mainProgram = "jerry";
    downloadPage = "https://github.com/jerryscript-project/jerryscript/";

    pkgConfigModules = [
      "libjerry-core"
      "libjerry-ext"
      "libjerry-port"
    ];
  };
})
