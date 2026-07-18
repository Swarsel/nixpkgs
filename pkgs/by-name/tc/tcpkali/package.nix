{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  bison,
}:

let
  version = "1.1.1";
in

stdenv.mkDerivation rec {
  inherit version;
  pname = "tcpkali";

  src = fetchFromGitHub {
    owner = "machinezone";
    repo = "tcpkali";
    rev = "v${version}";
    sha256 = "09ky3cccaphcqc6nhfs00pps99lasmzc2pf5vk0gi8hlqbbhilxf";
  };

  postPatch = ''
    sed -i -e '/sys\/sysctl\.h/d' src/tcpkali_syslimits.c
  '';

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ bison ];

  meta = {
    inherit (src.meta) homepage;
    description = "High performance TCP and WebSocket load generator and sink";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "tcpkali";
  };
}
