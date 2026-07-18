{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  buildOctavePackage,
  ffmpeg_7,
  pkg-config,
}:

buildOctavePackage rec {
  pname = "video";
  version = "2.1.3";

  src = fetchFromGitHub {
    owner = "Andy1978";
    repo = "octave-video";
    tag = version;
    hash = "sha256-fn9LNfuS9dSStBfzBjRRkvP50JJ5K+Em02J9+cHqt6w=";
  };

  nativeBuildInputs = [
    pkg-config
    autoconf
    automake
  ];

  propagatedBuildInputs = [
    ffmpeg_7
  ];

  preBuild = ''
    pushd src
    patchShebangs bootstrap configure
    ./bootstrap
    ./configure
    popd

    tar --transform 's,^,video-${version}/,' -cz * -f video-${version}.tar.gz
  '';

  meta = {
    description = "Wrapper for OpenCV's CvCapture_FFMPEG and CvVideoWriter_FFMPEG";
    homepage = "https://gnu-octave.github.io/packages/video/";

    license = with lib.licenses; [
      gpl3Plus
      bsd3
    ];

    maintainers = with lib.maintainers; [ ravenjoad ];
  };
}
