{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  jansson,
}:

stdenv.mkDerivation {
  pname = "jshon";
  version = "20170302";

  src = fetchFromGitHub {
    owner = "keenerd";
    repo = "jshon";
    rev = "d919aeaece37962251dbe6c1ee50f0028a5c90e4";
    sha256 = "1x4zfmsjq0l2y994bxkhx3mn5vzjxxr39iib213zjchi9h6yxvnc";
  };

  patches = [
    (fetchpatch {
      sha256 = "0kwbn3xb37iqb5y1n8vhzjiwlbg5jmki3f38pzakc24kzc5ksmaa";
      # https://github.com/keenerd/jshon/pull/62
      url = "https://github.com/keenerd/jshon/commit/96b4e9dbf578be7b31f29740b608aa7b34df3318.patch";
    })
  ];

  postPatch = ''
    substituteInPlace Makefile --replace "/usr/" "/"
  '';

  buildInputs = [ jansson ];
  env.NIX_CFLAGS_COMPILE = "-Wno-error=strict-prototypes";

  preInstall = ''
    export DESTDIR=$out
  '';

  meta = {
    description = "JSON parser designed for maximum convenience within the shell";
    homepage = "http://kmkeen.com/jshon";
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ rushmorem ];
    platforms = lib.platforms.all;
    mainProgram = "jshon";
  };
}
