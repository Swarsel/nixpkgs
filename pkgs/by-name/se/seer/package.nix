{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gdb,
  kdePackages,
}:

stdenv.mkDerivation rec {
  pname = "seer";
  version = "2.6";

  src = fetchFromGitHub {
    owner = "epasveer";
    repo = "seer";
    rev = "v${version}";
    sha256 = "sha256-QXVsjTJYGE/7nTKldlOGN6AnW8OthrBJruVbb/HiPdg=";
  };

  nativeBuildInputs = [
    cmake
    kdePackages.wrapQtAppsHook
  ];

  buildInputs = with kdePackages; [
    qtbase
    qtcharts
    qtsvg
  ];

  preConfigure = ''
    cd src
  '';

  patchPhase = ''
    substituteInPlace src/{SeerGdbConfigPage,SeerMainWindow,SeerGdbWidget}.cpp \
      --replace-fail "/usr/bin/gdb" "${gdb}/bin/gdb"
  '';

  meta = {
    description = "Qt gui frontend for GDB";
    homepage = "https://github.com/epasveer/seer";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ foolnotion ];
    platforms = lib.platforms.linux;
    mainProgram = "seergdb";
  };
}
