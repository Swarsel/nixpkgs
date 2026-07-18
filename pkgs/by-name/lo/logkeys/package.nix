{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  kbd,
  nixosTests,
  procps,
  which,
}:

stdenv.mkDerivation {
  pname = "logkeys";
  version = "2018-01-22";

  src = fetchFromGitHub {
    owner = "kernc";
    repo = "logkeys";
    rev = "7a9f19fb6b152d9f00a0b3fe29ab266ff1f88129";
    sha256 = "1k6kj0913imwh53lh6hrhqmrpygqg2h462raafjsn7gbd3vkgx8n";
  };

  postPatch = ''
    substituteInPlace src/Makefile.am --replace 'root' '$(id -u)'
    substituteInPlace configure.ac --replace '/dev/input' '/tmp'
    sed -i '/chmod u+s/d' src/Makefile.am
  '';

  nativeBuildInputs = [
    autoconf
    automake
  ];

  buildInputs = [
    which
    procps
    kbd
  ];

  preConfigure = "./autogen.sh";
  passthru.tests.nixos = nixosTests.logkeys;

  meta = {
    description = "GNU/Linux keylogger that works";
    homepage = "https://github.com/kernc/logkeys";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      mikoim
    ];

    platforms = lib.platforms.linux;
  };
}
