{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  fftwFloat,
  libjack2,
  libsigcxx,
  libxml2,
  pkg-config,
  wxwidgets_3_2,
}:

stdenv.mkDerivation {
  pname = "freqtweak";
  version = "unstable-2019-08-03";

  src = fetchFromGitHub {
    owner = "essej";
    repo = "freqtweak";
    rev = "d4205337558d36657a4ee6b3afb29358aa18c0fd";
    sha256 = "10cq27mdgrrc54a40al9ahi0wqd0p2c1wxbdg518q8pzfxaxs5fi";
  };

  nativeBuildInputs = [
    autoconf
    automake
    pkg-config
  ];

  buildInputs = [
    fftwFloat
    libjack2
    libsigcxx
    libxml2
    wxwidgets_3_2
  ];

  preConfigure = ''
    sh autogen.sh
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Realtime audio frequency spectral manipulation";
    homepage = "http://essej.net/freqtweak/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.magnetophon ];
    platforms = lib.platforms.linux;
    mainProgram = "freqtweak";
  };
}
