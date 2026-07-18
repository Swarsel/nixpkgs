{
  lib,
  stdenv,
  nim,
}:

stdenv.mkDerivation {
  inherit (nim) version;
  pname = "nim_builder";
  nativeBuildInputs = [ nim ];

  buildPhase = ''
    cp ${./nim_builder.nim} nim_builder.nim
    nim c --nimcache:$TMPDIR nim_builder
  '';

  installPhase = ''
    install -Dt $out/bin nim_builder
  '';

  dontUnpack = true;

  meta = {
    description = "Internal Nixpkgs utility for buildNimPackage";
    mainProgram = "nim_builder";
  };
}
