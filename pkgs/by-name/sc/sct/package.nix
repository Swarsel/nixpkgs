{
  lib,
  stdenv,
  fetchzip,
  libx11,
  libxrandr,
  xorgproto,
}:

stdenv.mkDerivation {
  pname = "sct";
  version = "0.5";

  src = fetchzip {
    url = "https://www.umaxx.net/dl/sct-0.5.tar.gz";
    sha256 = "sha256-nyYcdnCq8KcSUpc0HPCGzJI6NNrrTJLAHqPawfwPR/Q=";
  };

  buildInputs = [
    libx11
    libxrandr
    xorgproto
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  preInstall = ''
    mkdir -p $out/bin $out/share/man/man1
  '';

  meta = {
    description = "Minimal utility to set display colour temperature";
    homepage = "https://www.umaxx.net/";
    license = lib.licenses.isc;

    maintainers = with lib.maintainers; [
      raskin
      somasis
    ];

    platforms = with lib.platforms; linux ++ freebsd ++ openbsd;
  };
}
