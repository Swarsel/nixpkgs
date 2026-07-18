{
  lib,
  fetchFromGitHub,
  cmake,
  curl,
  libffi,
  libxml2,
  llvmPackages,
  python3,
  versionCheckHook,
  xar,
  checks ? true,
  debug ? false,
  rev ? "unknown",
}:
let
  inherit (lib.strings) optionalString;
in
llvmPackages.stdenv.mkDerivation (finalAttrs: {

  pname = "c3c${optionalString debug "-debug"}";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "c3lang";
    repo = "c3c";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6XUMlF9SRQ9aqVRl5BQdELVsj/DyXhCnH85QrbK8Xxo=";
  };

  postPatch = ''
    substituteInPlace git_hash.cmake \
      --replace-fail "\''${GIT_HASH}" "${rev}"
    substituteInPlace CMakeLists.txt \
      --replace-fail "-Werror" ""
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    llvmPackages.llvm
    llvmPackages.lld
    llvmPackages.compiler-rt
    curl
    libxml2
    libffi
  ]
  ++ lib.optionals llvmPackages.stdenv.hostPlatform.isDarwin [ xar ];

  cmakeFlags = [
    "-DC3_ENABLE_CLANGD_LSP=${if debug then "ON" else "OFF"}"
    "-DC3_LLD_DIR=${llvmPackages.lld.lib}/lib"
    "-DLLVM_CRT_LIBRARY_DIR=${llvmPackages.compiler-rt}/lib/darwin"
  ];

  doCheck =
    lib.elem llvmPackages.stdenv.system [
      "x86_64-linux"
      "aarch64-darwin"
    ]
    && checks;

  nativeCheckInputs = [ python3 ];

  checkPhase = ''
    runHook preCheck
    ( cd ../resources/testproject; ../../build/c3c build --trust=full )
    ( cd ../test; ../build/c3c compile-run -O1 src/test_suite_runner.c3 -- ../build/c3c test_suite )
    runHook postCheck
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  cmakeBuildType = if debug then "Debug" else "Release";

  meta = {
    description = "Compiler for the C3 language";
    homepage = "https://github.com/c3lang/c3c";
    license = lib.licenses.lgpl3Only;

    maintainers = with lib.maintainers; [
      hucancode
      anas
    ];

    platforms = lib.platforms.all;
    mainProgram = "c3c";
  };
})
