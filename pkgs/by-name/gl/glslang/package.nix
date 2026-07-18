{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  config,
  ctestCheckHook,
  gtest,
  python3,
  spirv-headers,
  spirv-tools,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "glslang";
  version = "16.3.0";

  src = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "glslang";
    tag = finalAttrs.version;
    hash = "sha256-wclcJ0NfqFXSUHGVsxjn2I8XxWbrkzOB4WXqsN1XtmE=";
  };

  outputs = [
    "bin"
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    python3
  ];

  propagatedBuildInputs = [
    spirv-tools
    spirv-headers
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
    (lib.cmakeBool "BUILD_EXTERNAL" false)
    (lib.cmakeBool "ALLOW_EXTERNAL_SPIRV_TOOLS" true)
    (lib.cmakeBool "ALLOW_EXTERNAL_GTEST" finalAttrs.finalPackage.doCheck)
  ];

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  nativeCheckInputs = [
    ctestCheckHook
  ];

  checkInputs = [
    gtest
  ];

  postInstall = ''
    # add a symlink for backwards compatibility
    ln -s $bin/bin/glslang $bin/bin/glslangValidator
  '';

  disabledTests =
    # CompileToAstTest.FromFile/array_frag looks for result of UB, expected output is LE
    # https://github.com/KhronosGroup/glslang/issues/2797
    # GlslNonSemanticShaderDebugInfoSpirv13Test.FromFile/spv_debuginfo_coopmatKHR_comp has endianness-issues
    # https://github.com/KhronosGroup/glslang/issues/4145
    lib.optionals (!stdenv.hostPlatform.isLittleEndian) [
      "glslang-gtests"
    ];

  passthru = lib.optionalAttrs config.allowAliases {
    # Added 2026-01-06, https://github.com/NixOS/nixpkgs/pull/477412
    spirv-headers = throw "'glslang' no longer pins to specific 'spirv-headers'";
    # Added 2026-01-06, https://github.com/NixOS/nixpkgs/pull/477412
    spirv-tools = throw "'glslang' no longer pins to specific 'spirv-tools'";
  };

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Khronos reference front-end for GLSL and ESSL";
    changelog = "https://github.com/KhronosGroup/glslang/blob/${finalAttrs.src.tag}/CHANGES.md";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.ralith ];
    platforms = lib.platforms.unix;
  };
})
