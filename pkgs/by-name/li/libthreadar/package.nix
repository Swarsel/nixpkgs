{
  lib,
  stdenv,
  fetchurl,
  gcc-unwrapped,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libthreadar";
  version = "1.5.0";

  src = fetchurl {
    url = "mirror://sourceforge/libthreadar/libthreadar-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-wJAkIUGK7Ud6n2p1275vNkSx/W7LlgKWXQaDevetPko=";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    # this field is not present on Darwin, ensure it is zero everywhere
    substituteInPlace src/thread_signal.cpp \
      --replace-fail 'sigac.sa_restorer = nullptr;' "" \
      --replace-fail 'struct sigaction sigac;' 'struct sigaction sigac = {0};'
  '';

  buildInputs = [ gcc-unwrapped ];

  configureFlags = [
    "--disable-build-html"
  ];

  env.CXXFLAGS = toString [ "-std=c++14" ];

  postInstall = ''
    # Disable html help
    rm -r "$out"/share
  '';

  meta = {
    description = "C++ library that provides several classes to manipulate threads";

    longDescription = ''
      Libthreadar is a C++ library providing a small set of C++ classes to manipulate
      threads in a very simple and efficient way from your C++ code.
    '';

    homepage = "https://libthreadar.sourceforge.net/";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ izorkin ];
    platforms = lib.platforms.unix;
  };
})
