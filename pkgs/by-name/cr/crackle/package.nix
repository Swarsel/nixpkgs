{
  lib,
  stdenv,
  fetchFromGitHub,
  coreutils,
  libpcap,
}:

stdenv.mkDerivation {
  pname = "crackle";
  version = "unstable-2020-12-13";

  src = fetchFromGitHub {
    owner = "mikeryan";
    repo = "crackle";
    rev = "d83b4b6f4145ca53c46c36bbd7ccad751af76b75";
    sha256 = "sha256-Dy4s/hr9ySrogltyk2GVsuAvwNF5+b6CDjaD+2FaPHA=";
  };

  buildInputs = [ libpcap ];

  installFlags = [
    "DESTDIR=$(out)"
    "PREFIX="
    "INSTALL=${coreutils}/bin/install"
  ];

  meta = {
    description = "Crack and decrypt BLE encryption";
    homepage = "https://github.com/mikeryan/crackle";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ moni ];
    mainProgram = "crackle";
  };
}
