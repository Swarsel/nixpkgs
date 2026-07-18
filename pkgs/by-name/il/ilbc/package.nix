{
  lib,
  stdenv,
  fetchurl,
  cmake,
  gawk,
}:

stdenv.mkDerivation rec {
  pname = "ilbc-rfc3951";
  version = "0-unstable-2004-12-03";

  src = fetchurl {
    url = "https://www.ietf.org/rfc/rfc3951.txt";
    sha256 = "0zf4mvi3jzx6zjrfl2rbhl2m68pzbzpf1vbdmn7dqbfpcb67jpdy";
  };

  nativeBuildInputs = [ cmake ];

  # Fixes the build with CMake 4
  cmakeFlags = [
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];

  script = ./extract-cfile.awk;

  unpackPhase = ''
    mkdir -v ${pname}
    cd ${pname}
    ${lib.getExe gawk} -f ${script} $src
    cp -v ${./CMakeLists.txt} CMakeLists.txt
  '';

  meta = {
    license = lib.licenses.free;
    platforms = lib.platforms.unix;
  };
}
