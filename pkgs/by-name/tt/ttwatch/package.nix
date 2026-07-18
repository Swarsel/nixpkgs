{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
  libusb1,
  openssl,
  perl,
  pkg-config,
  protobufc,
  enableUnsafe ? false,
}:

stdenv.mkDerivation {
  pname = "ttwatch";
  version = "2020-06-24";

  src = fetchFromGitHub {
    owner = "ryanbinns";
    repo = "ttwatch";
    rev = "260aff5869fd577d788d86b546399353d9ff72c1";
    sha256 = "0yd2hs9d03gfvwm1vywpg2qga6x5c74zrj665wf9aa8gmn96hv8r";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required (VERSION 2.8)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    perl
    pkg-config
  ];

  buildInputs = [
    openssl
    curl
    libusb1
    protobufc
  ];

  cmakeFlags = lib.optionals enableUnsafe [ "-Dunsafe=on" ];

  preFixup = ''
    chmod +x $out/bin/ttbin2mysports
  '';

  meta = {
    description = "Linux TomTom GPS Watch Utilities";
    homepage = "https://github.com/ryanbinns/ttwatch";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
    platforms = with lib.platforms; linux;
  };
}
