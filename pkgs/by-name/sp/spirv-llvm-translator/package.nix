{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  lit,
  llvm,
  pkg-config,
  pkgs,
  spirv-headers,
  spirv-tools,
  srcOnly,
}:

let
  llvmMajor = lib.versions.major llvm.version;

  versions = {
    "18" = rec {
      version = "18.1.15";
      hash = "sha256-rt3RTZut41uDEh0YmpOzH3sOezeEVWtAIGMKCHLSJBw=";
      rev = "v${version}";
    };

    "19" = rec {
      version = "19.1.10";
      hash = "sha256-VgA47AGMnOKYNeW95nxJZzmKnYK8D/9okgssPnPqXXI=";
      rev = "v${version}";
    };

    "20" = rec {
      version = "20.1.5";
      hash = "sha256-GdlC/Vl61nTNdua2s+CW2YOvkSKK6MNOvBc/393iths=";
      rev = "v${version}";
    };

    "21" = rec {
      version = "21.1.0";
      hash = "sha256-kk8BbPl/UBW1gaO/cuOQ9OsiNTEk0TkvRDLKUAh6exk=";
      rev = "v${version}";
    };

    "22" = rec {
      version = "22.1.3";
      hash = "sha256-u/OytBH9LgAyGF9PX+5lmAbGPQ7iVv52w8mwQ+6fi/s=";
      rev = "v${version}";
    };
  };

  branch =
    versions."${llvmMajor}" or {
      version = "${llvmMajor}.x.x";
      hash = "";
      rev = "";
    };
in
stdenv.mkDerivation {
  inherit (branch) version;
  pname = "SPIRV-LLVM-Translator";

  src = fetchFromGitHub {
    inherit (branch) rev hash;
    owner = "KhronosGroup";
    repo = "SPIRV-LLVM-Translator";
  };

  # TODO: Remove.
  patches = [ ];

  nativeBuildInputs = [
    pkg-config
    cmake
    llvm.dev
  ];

  buildInputs = [
    spirv-headers
    spirv-tools
    llvm
  ];

  cmakeFlags = [
    "-DLLVM_INCLUDE_TESTS=ON"
    "-DLLVM_DIR=${llvm.dev}"
    "-DBUILD_SHARED_LIBS=YES"
    "-DLLVM_SPIRV_BUILD_EXTERNAL=YES"
    # RPATH of binary /nix/store/.../bin/llvm-spirv contains a forbidden reference to /build/
    "-DCMAKE_SKIP_BUILD_RPATH=ON"
    "-DLLVM_EXTERNAL_SPIRV_HEADERS_SOURCE_DIR=${srcOnly spirv-headers}"
  ]
  ++ lib.optional (
    lib.toInt llvmMajor >= 19
  ) "-DBASE_LLVM_VERSION=${lib.versions.majorMinor llvm.version}.0";

  makeFlags = [
    "all"
    "llvm-spirv"
  ];

  # FIXME: CMake tries to run "/llvm-lit" which of course doesn't exist
  doCheck = false;
  nativeCheckInputs = [ lit ];

  postInstall = ''
    install -D tools/llvm-spirv/llvm-spirv $out/bin/llvm-spirv
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    install_name_tool $out/bin/llvm-spirv \
      -change @rpath/libLLVMSPIRVLib.dylib $out/lib/libLLVMSPIRVLib.dylib
  '';

  passthru.tests = lib.genAttrs (lib.attrNames versions) (
    version: pkgs.spirv-llvm-translator.override { llvm = pkgs."llvm_${version}"; }
  );

  meta = {
    description = "Tool and a library for bi-directional translation between SPIR-V and LLVM IR";
    homepage = "https://github.com/KhronosGroup/SPIRV-LLVM-Translator";
    license = lib.licenses.ncsa;
    maintainers = with lib.maintainers; [ gloaming ];
    platforms = lib.platforms.unix;
    mainProgram = "llvm-spirv";
    broken = !(versions ? ${llvmMajor});
  };
}
