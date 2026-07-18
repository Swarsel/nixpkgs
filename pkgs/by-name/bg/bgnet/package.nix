{
  lib,
  stdenv,
  fetchFromGitHub,
  pandoc,
  python3,
}:

stdenv.mkDerivation {
  pname = "bgnet";
  # to be found in the Makefile
  version = "3.1.2";

  src = fetchFromGitHub {
    owner = "beejjorgensen";
    repo = "bgnet";
    rev = "782a785a35d43c355951b8151628d7c64e4d0346";
    sha256 = "19w0r3zr71ydd29amqwn8q3npgrpy5kkshyshyji2hw5hky6iy92";
  };

  nativeBuildInputs = [
    python3
    pandoc
  ];

  buildPhase = ''
    # build scripts need some love
    patchShebangs bin/preproc

    make -C src bgnet.html
  '';

  installPhase = ''
    install -Dm644 src/bgnet.html $out/share/doc/bgnet/html/index.html
  '';

  meta = {
    description = "Beej’s Guide to Network Programming";
    homepage = "https://beej.us/guide/bgnet/";
    license = lib.licenses.unfree;
    maintainers = [ ];
  };
}
