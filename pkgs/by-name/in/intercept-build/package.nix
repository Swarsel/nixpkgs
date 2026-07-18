{
  lib,
  llvmPackages,
  python3,
}:
let
  inherit (llvmPackages) clang-unwrapped;
in
python3.pkgs.buildPythonApplication (finalAttrs: {
  inherit (clang-unwrapped) version;
  pname = "intercept-build";
  src = clang-unwrapped + "/bin";

  installPhase = ''
    mkdir -p "$out/bin"
    install "$src/intercept-build" "$out/bin"
  '';

  dependencies = with python3.pkgs; [
    libscanbuild
  ];

  dontUnpack = true;
  pyproject = false;

  meta = {
    description = "intercepts the build process to generate a compilation database";
    homepage = "https://github.com/llvm/llvm-project/tree/llvmorg-${finalAttrs.version}/clang/tools/scan-build-py/";

    license = with lib.licenses; [
      asl20
      llvm-exception
    ];

    maintainers = [ ];
    mainProgram = "intercept-build";
  };
})
