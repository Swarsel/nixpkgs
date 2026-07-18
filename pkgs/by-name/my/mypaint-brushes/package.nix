{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "mypaint-brushes";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "mypaint";
    repo = "mypaint-brushes";
    rev = "v${version}";
    sha256 = "0kcqz13vzpy24dhmrx9hbs6s7hqb8y305vciznm15h277sabpmw9";
  };

  nativeBuildInputs = [
    autoconf
    automake
    pkg-config
  ];

  preConfigure = "./autogen.sh";

  meta = {
    description = "Brushes used by MyPaint and other software using libmypaint";
    homepage = "http://mypaint.org/";
    license = lib.licenses.cc0;
    maintainers = with lib.maintainers; [ jtojnar ];
    platforms = lib.platforms.unix;
  };
}
