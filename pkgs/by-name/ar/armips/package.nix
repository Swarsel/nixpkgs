{
  lib,
  fetchFromGitHub,
  clangStdenv,
  cmake,
}:

clangStdenv.mkDerivation (finalAttrs: {
  pname = "armips";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "Kingcom";
    repo = "armips";
    tag = "v${finalAttrs.version}";
    hash = "sha256-L+Uxww/WtvDJn1xZqoqA6Pkzq/98sy1qTxZbv6eEjbA=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail c++11 c++17
  ''
  # done by https://github.com/Kingcom/armips/commit/e1ed5bf0f4565250b98b0ddfb9112f15dc8e8e3b upstream, patch not directly compatible
  + ''
    substituteInPlace CMakeLists.txt \
      --replace-fail \
        "cmake_minimum_required(VERSION 2.8)" \
        "cmake_minimum_required(VERSION 3.13)"
  '';

  nativeBuildInputs = [ cmake ];
  # Fix GCC 15 compatibility
  # error: unknown type name 'uint32_t'
  env.CXXFLAGS = "-include cstdint";
  doCheck = true;

  checkPhase = ''
    runHook preCheck
    ./armipstests ..
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp armips $out/bin

    runHook postInstall
  '';

  meta = {
    description = "Assembler for various ARM and MIPS platforms";
    homepage = "https://github.com/Kingcom/armips";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ marius851000 ];
    mainProgram = "armips";
  };
})
