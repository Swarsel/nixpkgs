{
  lib,
  stdenv,
  fetchurl,
  cmake,
  fetchpatch2,
  gettext,
  gtk2,
  harfbuzz,
  libcanberra,
  libnotify,
  libpthread-stubs,
  libxdmcp,
  pcre,
  pkg-config,
  sqlite,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libgaminggear";
  version = "0.15.1";

  src = fetchurl {
    url = "mirror://sourceforge/libgaminggear/libgaminggear-${finalAttrs.version}.tar.bz2";
    sha256 = "0jf5i1iv8j842imgiixbhwcr6qcwa93m27lzr6gb01ri5v35kggz";
  };

  outputs = [
    "dev"
    "out"
    "bin"
  ];

  patches = [
    (fetchpatch2 {
      hash = "sha256-loznfqxlucYlDUSYotMdUBmivKu+DD+OYhRIWpcrSgE=";
      url = "https://aur.archlinux.org/cgit/aur.git/plain/cmake_min_version.patch?h=libgaminggear&id=bfe7db62db76dbcefa8ba47640a35c80183f91d3";
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    gettext
  ];

  propagatedBuildInputs = [
    gtk2
    libcanberra
    libnotify
    pcre
    sqlite
    libxdmcp
    libpthread-stubs
  ];

  cmakeFlags = [
    "-DINSTALL_CMAKE_MODULESDIR=lib/cmake"
    "-DINSTALL_PKGCONFIGDIR=lib/pkgconfig"
    "-DINSTALL_LIBDIR=lib"
  ];

  # https://sourceforge.net/p/libgaminggear/discussion/general/thread/b43a776b3a/
  env.NIX_CFLAGS_COMPILE = toString [ "-I${harfbuzz.dev}/include/harfbuzz" ];

  postFixup = ''
    moveToOutput bin "$bin"
  '';

  meta = {
    description = "Provides functionality for gaming input devices";
    homepage = "https://sourceforge.net/projects/libgaminggear/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
})
