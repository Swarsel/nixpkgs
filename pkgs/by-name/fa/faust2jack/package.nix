{
  alsa-lib,
  bash,
  faust,
  gtk2,
  jack2,
  libsndfile,
  opencv,
  which,
}:

faust.wrapWithBuildEnv {

  buildInputs = [
    bash # required for some scripts
  ];

  propagatedBuildInputs = [
    gtk2
    jack2
    alsa-lib
    opencv
    libsndfile
    which
  ];

  baseName = "faust2jack";

  scripts = [
    "faust2jack"
    "faust2jackconsole"
  ];

}
