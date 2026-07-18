{
  faust,
  flac,
  lame,
  libmpg123,
  libogg,
  libopus,
  libsndfile,
  libvorbis,
}:

faust.wrapWithBuildEnv {

  propagatedBuildInputs = [
    flac
    lame
    libmpg123
    libogg
    libopus
    libsndfile
    libvorbis
  ];

  baseName = "faust2sndfile";

}
