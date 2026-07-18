{
  lib,
  chromium,
  ffmpeg-headless,
  makeWrapper,
  mcat-unwrapped,
  runCommand,
  useChromium ? false,
  useFfmpeg ? false,
}:

runCommand "mcat"
  {
    inherit (mcat-unwrapped) version meta;
    pname = "mcat";
    nativeBuildInputs = [ makeWrapper ];
  }
  ''
    mkdir -p $out/bin
    ln -s "${mcat-unwrapped}/share" "$out/share"
    makeWrapper ${lib.getExe mcat-unwrapped} $out/bin/mcat --prefix PATH : ${
      lib.makeBinPath ((lib.optional useChromium chromium) ++ (lib.optional useFfmpeg ffmpeg-headless))
    }
  ''
