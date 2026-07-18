{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  libpcap,
  libtool,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libcrafter";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "pellegre";
    repo = "libcrafter";
    rev = "version-${finalAttrs.version}";
    sha256 = "sha256-tCdN3+EzISVl+wp5umOFD+bgV+uUdabH+2LyxlV/W7Q=";
  };

  nativeBuildInputs = [
    autoconf
    automake
  ];

  buildInputs = [ libtool ];
  propagatedBuildInputs = [ libpcap ];
  configureFlags = [ "--with-libpcap=yes" ];
  preConfigure = "cd libcrafter";
  configureScript = "./autogen.sh";

  meta = {
    description = "High level C++ network packet sniffing and crafting library";
    homepage = "https://github.com/pellegre/libcrafter";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
