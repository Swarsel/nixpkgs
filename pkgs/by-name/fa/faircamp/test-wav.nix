{
  stdenv,
  faircamp,
  ffmpeg,
}:

stdenv.mkDerivation {
  buildCommand = ''
    mkdir album
    ${ffmpeg}/bin/ffmpeg -f lavfi -i "sine=frequency=440:duration=1" album/track.wav
    ${faircamp}/bin/faircamp --build-dir $out
  '';

  name = "faircamp-test-wav";
  meta.timeout = 60;
}
