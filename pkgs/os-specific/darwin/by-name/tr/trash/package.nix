{
  lib,
  stdenv,
  fetchFromGitHub,
  perl,
}:

stdenv.mkDerivation rec {
  pname = "trash";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "ali-rantakari";
    repo = "trash";
    rev = "v${version}";
    sha256 = "1d3rc03vgz32faj7qi18iiggxvxlqrj9lsk5jkpa9r1mcs5d89my";
  };

  patches = [ ./trash.diff ];

  buildInputs = [
    perl
  ];

  buildPhase = "make all docs";

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/man/man1
    install -m 0755 trash $out/bin
    install -m 0444 trash.1 $out/share/man/man1
  '';

  meta = {
    description = "Small command-line program for OS X that moves files or
    folders to the trash.";

    homepage = "https://github.com/ali-rantakari/trash";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
  };
}
