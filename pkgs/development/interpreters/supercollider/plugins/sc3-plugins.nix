{
  lib,
  stdenv,
  fetchurl,
  cmake,
  fetchpatch2,
  fftw,
  fftwFloat,
  gitUpdater,
  supercollider,
}:

stdenv.mkDerivation rec {
  pname = "sc3-plugins";
  version = "3.14.0";

  src = fetchurl {
    url = "https://github.com/supercollider/sc3-plugins/releases/download/Version-${version}/sc3-plugins-${version}-Source.tar.bz2";
    sha256 = "sha256-CW9JVVdgeITg2/0TLprw1V8WW4VhBmCN2Ns8XmiZKh0=";
  };

  strictDeps = true;
  nativeBuildInputs = [ cmake ];

  buildInputs = [
    supercollider
    fftw
    fftwFloat # builds without this will return an error message about no FFTW3F-INCLUDE-DIR
  ];

  cmakeFlags = [
    "-DSC_PATH=${supercollider}/include/SuperCollider"
    "-DSUPERNOVA=ON"
  ];

  stripDebugList = [
    "lib"
    "share"
  ];

  passthru.updateScript = gitUpdater {
    ignoredVersions = "rc|beta";
    rev-prefix = "Version-";
    url = "https://github.com/supercollider/sc3-plugins.git";
  };

  meta = {
    description = "Community plugins for SuperCollider";
    homepage = "https://supercollider.github.io/sc3-plugins/";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      pretentiousUsername
    ];

    platforms = lib.platforms.linux;
  };
}
