{
  lib,
  stdenv,
  fetchurl,
  cmake,
  libxml2,
  libzip,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ebook-tools";
  version = "0.2.2";

  src = fetchurl {
    url = "mirror://sourceforge/ebook-tools/ebook-tools-${finalAttrs.version}.tar.gz";
    sha256 = "1bi7wsz3p5slb43kj7lgb3r6lb91lvb6ldi556k4y50ix6b5khyb";
  };

  # Fix the build with CMake 4.
  #
  # See: <https://sourceforge.net/p/ebook-tools/bugs/14/>
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail \
        'cmake_minimum_required(VERSION 2.4.0)' \
        'cmake_minimum_required(VERSION 3.10)'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libxml2
    libzip
  ];

  meta = {
    description = "Tools and library for dealing with various ebook file formats";
    homepage = "http://ebook-tools.sourceforge.net";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
