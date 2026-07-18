{
  lib,
  stdenv,
  fetchurl,
  gnutls,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ucommon";
  version = "7.0.0";

  src = fetchurl {
    url = "mirror://gnu/commoncpp/ucommon-${finalAttrs.version}.tar.gz";
    sha256 = "6ac9f76c2af010f97e916e4bae1cece341dc64ca28e3881ff4ddc3bc334060d7";
  };

  # disable flaky networking test
  postPatch = ''
    substituteInPlace test/stream.cpp \
      --replace 'ifndef UCOMMON_SYSRUNTIME' 'if 0'
  '';

  nativeBuildInputs = [ pkg-config ];
  # ucommon.pc has link time dependencies on -lusecure -lucommon -lgnutls
  propagatedBuildInputs = [ gnutls ];
  # use C++14 Standard until error handling code gets updated upstream
  env.CXXFLAGS = toString [ "-std=c++14" ];
  doCheck = true;

  meta = {
    description = "C++ library to facilitate using C++ design patterns";
    homepage = "https://www.gnu.org/software/commoncpp/";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
