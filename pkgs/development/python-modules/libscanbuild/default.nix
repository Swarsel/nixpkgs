{
  lib,
  buildPythonPackage,
  libear,
  llvmPackages,
}:
let
  inherit (llvmPackages) clang-unwrapped;
in
buildPythonPackage rec {
  inherit (clang-unwrapped) version;
  pname = "libscanbuild";
  src = clang-unwrapped.lib + "/lib/libscanbuild";

  installPhase = ''
    LIBPATH="$(toPythonPath "$out")/libscanbuild"
    mkdir -p "$LIBPATH"

    cp -r "$src/"* "$LIBPATH"
  '';

  dependencies = [
    libear
  ];

  dontUnpack = true;
  pyproject = false;
  pythonImportsCheck = [ "libscanbuild" ];

  meta = {
    description = "Captures all child process creation and log information about it";
    homepage = "https://github.com/llvm/llvm-project/tree/llvmorg-${version}/clang/tools/scan-build-py/lib/libscanbuild";

    license = with lib.licenses; [
      asl20
      llvm-exception
    ];

    maintainers = [ ];
  };
}
