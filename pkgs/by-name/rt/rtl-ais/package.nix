{
  lib,
  stdenv,
  fetchFromGitHub,
  libusb1,
  pkg-config,
  rtl-sdr,
}:

stdenv.mkDerivation {
  pname = "rtl-ais";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "dgiardini";
    repo = "rtl-ais";
    rev = "0e85f4e5f9ce7378834c3129bc894580efc24291";
    sha256 = "0wm4zai1vs89mf0zgz52q5w5rj8f3i3v6zg42hfb7aqabi25r3jf";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    rtl-sdr
    libusb1
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Simple AIS tuner and generic dual-frequency FM demodulator";
    homepage = "https://github.com/dgiardini/rtl-ais";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ mgdm ];
    platforms = lib.platforms.unix;
    mainProgram = "rtl_ais";
  };
}
