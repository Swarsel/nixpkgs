{
  lib,
  stdenv,
  fasm-bin,
  isx86_64,
}:

stdenv.mkDerivation {
  inherit (fasm-bin) version src meta;
  pname = "fasm";

  outputs = [
    "out"
    "doc"
  ];

  nativeBuildInputs = [ fasm-bin ];

  buildPhase = ''
    fasm source/linux${lib.optionalString isx86_64 "/x64"}/fasm.asm fasm
    for tool in listing prepsrc symbols; do
      fasm tools/libc/$tool.asm
      cc -o tools/libc/fasm-$tool tools/libc/$tool.o
    done
  '';

  installPhase = ''
    install -Dt $out/bin fasm tools/libc/fasm-*

    docs=$doc/share/doc/fasm
    mkdir -p $docs
    cp -r examples/ *.txt tools/fas.txt $docs
    cp tools/readme.txt $docs/tools.txt
  '';

  passthru.updateScript = fasm-bin.updateScript;
}
