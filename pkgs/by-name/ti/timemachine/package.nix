{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  gtk2,
  libjack2,
  libsndfile,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "timemachine";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "swh";
    repo = "timemachine";
    rev = "v${finalAttrs.version}";
    sha256 = "16fgyw6jnscx9279dczv72092dddghwlp53rkfw469kcgvjhwx0z";
  };

  nativeBuildInputs = [
    pkg-config
    autoconf
    automake
  ];

  buildInputs = [
    gtk2
    libjack2
    libsndfile
  ];

  env.NIX_LDFLAGS = "-lm";
  preConfigure = "./autogen.sh";

  meta = {
    description = "JACK audio recorder";
    homepage = "http://plugin.org.uk/timemachine/";
    license = lib.licenses.lgpl2;
    maintainers = [ lib.maintainers.nico202 ];
    platforms = lib.platforms.linux;
    mainProgram = "timemachine";
  };
})
