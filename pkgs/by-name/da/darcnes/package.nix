{
  lib,
  stdenv,
  fetchurl,
  libx11,
  libxaw,
  libxext,
  libxt,
}:

stdenv.mkDerivation rec {
  pname = "darcnes";
  version = "9b0401";

  src = fetchurl {
    url = "https://web.archive.org/web/20130511081532/http://www.dridus.com/~nyef/darcnes/download/dn${version}.tgz";
    sha256 = "05a7mh51rg7ydb414m3p5mm05p4nz2bgvspqzwm3bhbj7zz543k3";
  };

  patches = [ ./label.patch ];

  buildInputs = [
    libx11
    libxt
    libxext
    libxaw
  ];

  installPhase = "install -Dt $out/bin darcnes";

  meta = {
    description = "Sega Master System, Game Gear, SG-1000, NES, ColecoVision and Apple II emulator";
    homepage = "https://web.archive.org/web/20130502171725/http://www.dridus.com/~nyef/darcnes/";
    # Prohibited commercial use, credit required.
    license = lib.licenses.free;
    platforms = [ "i686-linux" ];
  };
}
