{
  lib,
  stdenv,
  cmake,
  fetchsvn,
  libftdi1,
  libusb-compat-0_1,
  pkg-config,
}:

# The xc3sprog project doesn't seem to make proper releases, they only put out
# prebuilt binary subversion snapshots on sourceforge.

stdenv.mkDerivation (finalAttrs: {
  pname = "xc3sprog";
  version = "795";

  src = fetchsvn {
    url = "https://svn.code.sf.net/p/xc3sprog/code/trunk";
    rev = finalAttrs.version;
    sha256 = "sha256-E0MGwC3gIfl60gjGaSeSPTR5jJm9r8m7Et3402lek/w=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.6)" "cmake_minimum_required(VERSION 3.10)"
    substituteInPlace javr/CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.6)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libusb-compat-0_1
    libftdi1
  ];

  cmakeFlags = [
    # file RPATH_CHANGE could not write new RPATH
    "-DCMAKE_SKIP_BUILD_RPATH=ON"
    # fix build with gcc 11+
    "-DCMAKE_CXX_STANDARD=14"
  ];

  meta = {
    description = "Command-line tools for programming FPGAs, microcontrollers and PROMs via JTAG";
    homepage = "https://xc3sprog.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.bjornfor ];
    platforms = lib.platforms.linux;
  };
})
