{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  libexif,
  libjpeg,
  libtool,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "epeg";
  version = "0.9.3";

  src = fetchFromGitHub {
    owner = "mattes";
    repo = "epeg";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-lttqarR8gScNIlSrc5uU3FLfvwxxJ2A1S4oESUW7oIw=";
  };

  nativeBuildInputs = [
    pkg-config
    libtool
    autoconf
    automake
  ];

  propagatedBuildInputs = [
    libjpeg
    libexif
  ];

  preConfigure = ''
    ./autogen.sh
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Insanely fast JPEG/ JPG thumbnail scaling";
    homepage = "https://github.com/mattes/epeg";
    license = lib.licenses.mit-enna;
    maintainers = with lib.maintainers; [ nh2 ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "epeg";
  };
})
