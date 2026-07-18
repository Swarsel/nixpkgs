{
  lib,
  stdenv,
  fetchurl,
  flac,
  gnuplot,
  id3v2,
  makeWrapper,
  sox,
  vorbis-tools,
}:

let
  path = lib.makeBinPath [
    gnuplot
    sox
    flac
    id3v2
    vorbis-tools
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "bpm-tools";
  version = "0.3";

  src = fetchurl {
    url = "https://www.pogo.org.uk/~mark/bpm-tools/releases/bpm-tools-${finalAttrs.version}.tar.gz";
    sha256 = "151vfbs8h3cibs7kbdps5pqrsxhpjv16y2iyfqbxzsclylgfivrp";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  postFixup = ''
    wrapProgram $out/bin/bpm-tag --prefix PATH : "${path}"
    wrapProgram $out/bin/bpm-graph --prefix PATH : "${path}"
  '';

  installFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  meta = {
    description = "Automatically calculate BPM (tempo) of music files";
    homepage = "http://www.pogo.org.uk/~mark/bpm-tools/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ doronbehar ];
    platforms = lib.platforms.all;
  };
})
