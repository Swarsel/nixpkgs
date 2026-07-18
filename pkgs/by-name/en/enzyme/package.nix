{
  lib,
  fetchFromGitHub,
  cmake,
  git,
  llvmPackages,
}:
llvmPackages.stdenv.mkDerivation rec {
  pname = "enzyme";
  version = "0.0.280";

  src = fetchFromGitHub {
    owner = "EnzymeAD";
    repo = "Enzyme";
    rev = "v${version}";
    hash = "sha256-EVs7gBEDFINdbob51AlUsgH21sR/V/5/Cc+ADnOwDgM=";
  };

  postPatch = ''
    patchShebangs enzyme
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    git
    llvm
    clang
  ];

  cmakeFlags = [
    "-DLLVM_DIR=${llvm.dev}"
    "-DClang_DIR=${clang.dev}"
  ];

  clang = llvmPackages.clang-unwrapped;
  cmakeDir = "../enzyme";
  enableParallelBuilding = true;
  llvm = llvmPackages.llvm;

  meta = {
    description = "High-performance automatic differentiation of LLVM and MLIR";
    homepage = "https://enzyme.mit.edu/";

    license = with lib.licenses; [
      asl20
      llvm-exception
    ];

    maintainers = with lib.maintainers; [ kiranshila ];
    platforms = lib.platforms.all;
  };
}
