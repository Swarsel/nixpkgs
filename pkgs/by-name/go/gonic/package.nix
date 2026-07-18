{
  lib,
  fetchFromGitHub,
  buildGoModule,
  ffmpeg,
  mpv,
  nixosTests,
  pkg-config,
  taglib,
  zlib,
  # Setting this to false does not disable the jukebox feature,
  # but avoids the dependency on mpv at least.
  jukeboxSupport ? true,
  # Disable on-the-fly transcoding,
  # removing the dependency on ffmpeg.
  # The server will (as of 0.11.0) gracefully fall back
  # to the original file, but if transcoding is configured
  # that takes a while. So best to disable all transcoding
  # in the configuration if you disable transcodingSupport.
  transcodingSupport ? true,
}:

buildGoModule (finalAttrs: {
  pname = "gonic";
  version = "0.22.0";

  src = fetchFromGitHub {
    owner = "sentriz";
    repo = "gonic";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-I0+5mzybWc8NP3yfePFyHEsSTDfniYQjIaZpe4djGGM=";
  };

  # TODO(Profpatsch): write a test for transcoding support,
  # since it is prone to break
  postPatch =
    lib.optionalString transcodingSupport ''
      substituteInPlace \
        transcode/transcode.go \
        --replace-fail \
          '`ffmpeg' \
          '`${lib.getBin ffmpeg}/bin/ffmpeg'
    ''
    + lib.optionalString jukeboxSupport ''
      substituteInPlace \
        jukebox/jukebox.go \
        --replace-fail \
          '"mpv"' \
          '"${lib.getBin mpv}/bin/mpv"'
    ''
    + ''
      substituteInPlace server/ctrlsubsonic/testdata/test* \
        --replace-quiet \
          '"audio/flac"' \
          '"audio/x-flac"'
    '';

  vendorHash = "sha256-OynYgtqWNMyrUvysi9cNqL0nAfUXP8cOEx02lSP6E7E=";
  # tests require it
  __darwinAllowLocalNetworking = true;

  passthru = {
    tests.gonic = nixosTests.gonic;
  };

  meta = {
    description = "Music streaming server / subsonic server API implementation";
    homepage = "https://github.com/sentriz/gonic";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ autrimpo ];
    mainProgram = "gonic";
  };
})
