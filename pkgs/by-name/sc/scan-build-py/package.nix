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
  pname = "scan-build-py";
  src = clang-unwrapped + "/bin";

  installPhase = ''
    mkdir -p "$out/bin"
    install "$src/scan-build-py" "$out/bin/scan-build-py"
  '';

  dependencies = with python3.pkgs; [
    libscanbuild
  ];

  dontUnpack = true;

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [ clang-unwrapped ])
  ];

  pyproject = false;

  meta = {
    description = "intercepts the build process to generate a compilation database";
    homepage = "https://github.com/llvm/llvm-project/tree/llvmorg-${finalAttrs.version}/clang/tools/scan-build-py/";

    license = with lib.licenses; [
      asl20
      llvm-exception
    ];

    maintainers = [ ];
    platforms = lib.intersectLists python3.meta.platforms clang-unwrapped.meta.platforms;
    mainProgram = "scan-build-py";
  };
})
