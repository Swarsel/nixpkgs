{
  lib,
  stdenv,
  fetchFromGitHub,
  ace,
  cmake,
  nix-update-script,
  ycm-cmake-modules,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "yarp";
  version = "3.12.2";

  src = fetchFromGitHub {
    owner = "robotology";
    repo = "yarp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Lx9ZCTFrSvO/PCB9lrz3f0avBzDAzEZINoqzlH2F6Xw=";
  };

  patches = [
    # Weird string interpolation causes compilation to fail due to -Wformat-security.
    ./0001-format-security.patch
  ];

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    ace
    ycm-cmake-modules
  ];

  cmakeFlags = [
    "-DYARP_COMPILE_UNMAINTAINED:BOOL=ON"
    "-DCREATE_YARPC:BOOL=ON"
    "-DCREATE_YARPCXX:BOOL=ON"
    "-DCMAKE_INSTALL_LIBDIR=${placeholder "out"}/lib"
  ];

  postInstall = "mv ./$out/lib/*.so $out/lib/";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Yet Another Robot Platform";
    homepage = "http://yarp.it";
    license = lib.licenses.lgpl21;
    maintainers = [ lib.maintainers.nico202 ];
    platforms = lib.platforms.linux;
  };
})
