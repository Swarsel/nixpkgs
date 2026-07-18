{
  lib,
  stdenv,
  fetchFromGitHub,
  cctools,
  cmake,
  darwin,
  glslang,
  python3,
  replaceVars,
  spirv-tools,
  testers,
  versionCheckHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "shaderc";
  version = "2026.1";

  src = fetchFromGitHub {
    owner = "google";
    repo = "shaderc";
    rev = "v${finalAttrs.version}";
    hash = "sha256-OiBv18zxeE/gqY4zOMXTsCdkAEWo9BIehdu/adw0+cE=";
  };

  outputs = [
    "out"
    "lib"
    "bin"
    "dev"
    "static"
  ];

  patches = [
    (replaceVars ./unvendor-glslang.patch {
      glslang-version = glslang.version;
      shaderc-version = finalAttrs.version;
      spirv-tools-version = spirv-tools.version;
    })

    # https://github.com/google/shaderc/pull/1529
    ./fix-pc-file-generation.patch
  ];

  postPatch = ''
    patchShebangs --build utils/
  '';

  nativeBuildInputs = [
    cmake
    python3
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ cctools ]
  ++ lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
    darwin.autoSignDarwinBinariesHook
  ];

  propagatedBuildInputs = [
    glslang
  ];

  cmakeFlags = [ "-DSHADERC_SKIP_TESTS=ON" ];

  postInstall = ''
    moveToOutput "lib/*.a" $static
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  versionCheckProgramArg = "--version";

  passthru.tests.pkg-config = testers.hasPkgConfigModules {
    package = finalAttrs.finalPackage;
    # The version in pc files has `.1` appended to indicate that it's not a dev version
    versionCheck = false;
  };

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Collection of tools, libraries and tests for shader compilation";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
    mainProgram = "glslc";

    pkgConfigModules = [
      "shaderc_combined"
      "shaderc"
      "shaderc_static"
    ];
  };
})
