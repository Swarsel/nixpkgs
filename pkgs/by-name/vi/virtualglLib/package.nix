{
  lib,
  stdenv,
  fetchurl,
  cmake,
  fltk_1_3,
  libGL,
  libGLU,
  libjpeg_turbo,
  libxcb-keysyms,
  libxi,
  libxtst,
  libxv,
  ocl-icd,
  opencl-clhpp,
  opencl-headers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "virtualgl-lib";
  version = "3.0.2";

  src = fetchurl {
    url = "mirror://sourceforge/virtualgl/VirtualGL-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-OIEbwAQ71yOuHIzM+iaK7QkUJrKg6sXpGuFQOUPjM2w=";
  };

  postPatch = ''
    # the unit tests take significant hacks to build and can't run anyway due to the lack
    # of a 3D X server in the build sandbox. so we just chop out their build instructions.
    head -n $(grep -n 'UNIT TESTS' server/CMakeLists.txt | cut -d : -f 1) server/CMakeLists.txt > server/CMakeLists2.txt
    mv server/CMakeLists2.txt server/CMakeLists.txt
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    libjpeg_turbo
    libGL
    libGLU
    fltk_1_3
    libxv
    libxtst
    libxi
    libxcb-keysyms
    opencl-headers
    opencl-clhpp
    ocl-icd
  ];

  cmakeFlags = [
    "-DVGL_SYSTEMFLTK=1"
    "-DTJPEG_LIBRARY=${libjpeg_turbo.out}/lib/libturbojpeg.so"
    (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "4.0")
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  fixupPhase = ''
    substituteInPlace $out/bin/vglrun \
      --replace "LD_PRELOAD=libvglfaker" "LD_PRELOAD=$out/lib/libvglfaker" \
      --replace "LD_PRELOAD=libdlfaker" "LD_PRELOAD=$out/lib/libdlfaker" \
      --replace "LD_PRELOAD=libgefaker" "LD_PRELOAD=$out/lib/libgefaker"
  '';

  meta = {
    description = "X11 GL rendering in a remote computer with full 3D hw acceleration";
    homepage = "https://www.virtualgl.org/";

    license = with lib.licenses; [
      lgpl2Plus
      wxWindowsException31
    ];

    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
