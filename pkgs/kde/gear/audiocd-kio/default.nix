{
  lib,
  cdparanoia,
  flac,
  lame,
  libogg,
  libvorbis,
  mkKdeDerivation,
  opus-tools,
  replaceVars,
}:
mkKdeDerivation {
  pname = "audiocd-kio";

  patches = [
    (replaceVars ./encoder-paths.patch {
      lame = lib.getExe lame;
      opusenc = "${opus-tools}/bin/opusenc";
    })
  ];

  extraBuildInputs = [
    cdparanoia
    flac
    libogg
    libvorbis
  ];
}
