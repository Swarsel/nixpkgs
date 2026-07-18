{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  openssl,
  xxhash,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xva-img";
  version = "1.5";

  src = fetchFromGitHub {
    owner = "eriklax";
    repo = "xva-img";
    tag = finalAttrs.version;
    hash = "sha256-YyWfN6VcEABmzHkkoA/kRehLum1UxsNJ58XBs1pl+c8=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "CMAKE_MINIMUM_REQUIRED(VERSION 3.0)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    openssl
    xxhash
  ];

  meta = {
    description = "Tool for converting Xen images to raw and back";
    homepage = "https://github.com/eriklax/xva-img";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "xva-img";
  };
})
