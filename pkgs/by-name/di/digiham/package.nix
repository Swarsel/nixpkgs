{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  codecserver,
  csdr,
  icu,
  protobuf,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "digiham";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "jketterl";
    repo = "digiham";
    tag = finalAttrs.version;
    hash = "sha256-v7qp6Lv94Ec0yzHsc08YDfE5OU54nglosRLWb98yDiQ=";
  };

  patches = [
    # libicu headers require C++ 17, remove `set(CMAKE_CXX_STANDARD 11)`
    ./cpp-17.patch
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail \
      "cmake_minimum_required (VERSION 3.0)" \
      "cmake_minimum_required (VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    codecserver
    protobuf
    csdr
    icu
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/dmr_decoder";

  meta = {
    description = "Tools for decoding digital ham communication";
    homepage = "https://github.com/jketterl/digiham";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.unix;
  };
})
