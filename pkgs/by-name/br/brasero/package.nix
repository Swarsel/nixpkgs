{
  lib,
  brasero-unwrapped,
  cdrtools,
  libdvdcss,
  makeWrapper,
  symlinkJoin,
}:

let
  binPath = lib.makeBinPath [ cdrtools ];
in
symlinkJoin {
  inherit (brasero-unwrapped) meta version;
  pname = "brasero";
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/brasero \
      --prefix PATH ':' ${binPath} \
      --prefix LD_PRELOAD : ${lib.makeLibraryPath [ libdvdcss ]}/libdvdcss.so
  '';

  paths = [ brasero-unwrapped ];
}
