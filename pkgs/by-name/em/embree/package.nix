{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  glfw,
  glib,
  ispc,
  libjpeg,
  libpng,
  libpthread-stubs,
  libx11,
  onetbb,
  openimageio,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "embree";
  version = "4.4.1";

  src = fetchFromGitHub {
    owner = "RenderKit";
    repo = "embree";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZJItp33XUmaTk5s4AbM/uzWGxSdGh5scdZAZDBYy28M=";
  };

  postPatch = ''
    # Fix duplicate /nix/store/.../nix/store/.../ paths
    sed -i "s|SET(EMBREE_ROOT_DIR .*)|set(EMBREE_ROOT_DIR $out)|" \
      common/cmake/embree-config.cmake
    sed -i "s|$""{EMBREE_ROOT_DIR}/||" common/cmake/embree-config.cmake
    substituteInPlace common/math/emath.h --replace 'defined(__MACOSX__) && !defined(__INTEL_COMPILER)' 0
    substituteInPlace common/math/emath.h --replace 'defined(__WIN32__) || defined(__FreeBSD__)' 'defined(__WIN32__) || defined(__FreeBSD__) || defined(__MACOSX__)'
  '';

  nativeBuildInputs = [
    ispc
    pkg-config
    cmake
  ];

  buildInputs = [
    onetbb
    glfw
    openimageio
    libjpeg
    libpng
    libx11
    libpthread-stubs
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ glib ];

  cmakeFlags = [
    "-DEMBREE_TUTORIALS=OFF"
    "-DEMBREE_RAY_MASK=ON"
    "-DTBB_ROOT=${onetbb}"
    "-DTBB_INCLUDE_DIR=${onetbb.dev}/include"
  ];

  meta = {
    description = "High performance ray tracing kernels from Intel";
    homepage = "https://embree.github.io/";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
