{
  lib,
  buildPythonPackage,
  llvmPackages,
}:
let
  inherit (llvmPackages) clang-unwrapped;
in
buildPythonPackage rec {
  inherit (clang-unwrapped) version;
  pname = "libear";
  src = clang-unwrapped.lib + "/lib/libear";

  installPhase = ''
    LIBPATH="$(toPythonPath "$out")/libear"
    mkdir -p "$LIBPATH"

    install -t "$LIBPATH" $src/*
  '';

  dontUnpack = true;
  pyproject = false;
  pythonImportsCheck = [ "libear" ];

  meta = {
    description = "Hooks into build systems to listen to which files are opened";
    homepage = "https://github.com/llvm/llvm-project/tree/llvmorg-${version}/clang/tools/scan-build-py/lib/libear";

    license = with lib.licenses; [
      asl20
      llvm-exception
    ];

    maintainers = [ ];
  };
}
