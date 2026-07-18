{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  hdf5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "minia";
  version = "3.2.1";

  src = fetchFromGitHub {
    owner = "GATB";
    repo = "minia";
    tag = "v${finalAttrs.version}";
    sha256 = "0bmfrywixaaql898l0ixsfkhxjf2hb08ssnqzlzacfizxdp46siq";
    fetchSubmodules = true;
  };

  patches = [ ./no-bundle.patch ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required (VERSION 2.6)" "cmake_minimum_required(VERSION 3.10)"
    substituteInPlace thirdparty/gatb-core/gatb-core/CMakeLists.txt \
      --replace-fail "cmake_minimum_required (VERSION 3.1.0)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    hdf5
    boost
  ];

  env.NIX_CFLAGS_COMPILE = toString [ "-Wformat" ];

  prePatch = ''
    rm -rf thirdparty/gatb-core/gatb-core/thirdparty/{hdf5,boost}
  '';

  meta = {
    description = "Short read genome assembler";
    homepage = "https://github.com/GATB/minia";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ jbedo ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "minia";
  };
})
