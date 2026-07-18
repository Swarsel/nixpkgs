{
  lib,
  stdenv,
  fetchFromGitHub,
  check,
  cmake,
  expat,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "libwbxml";
  version = "0.11.10";

  src = fetchFromGitHub {
    owner = "libwbxml";
    repo = "libwbxml";
    rev = "${pname}-${version}";
    sha256 = "sha256-yy8+CyNKXuttCmxRxH/XptIloDklto4f5Zg0vnwnneY=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    check
  ];

  buildInputs = [ expat ];

  meta = {
    description = "WBXML Library (aka libwbxml) contains a library and its associated tools to Parse, Encode and Handle WBXML documents";
    homepage = "https://github.com/libwbxml/libwbxml";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ mh ];
    platforms = lib.platforms.unix;
  };
}
