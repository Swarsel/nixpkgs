{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libiconv,
  popt,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libnatspec";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "Etersoft";
    repo = "libnatspec";
    rev = "0.3.3-alt1";
    hash = "sha256-lg3kjrvv7G+nX6xlR7TQKvXqQJFcQTHarSpD0qYLZsw=";
  };

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ popt ];
  propagatedBuildInputs = [ libiconv ];

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    NIX_LDFLAGS = "-liconv";
  };

  meta = {
    description = "Library intended to smooth national specificities in using of programs";
    homepage = "https://github.com/Etersoft/libnatspec";
    license = lib.licenses.lgpl21;
    platforms = lib.platforms.unix;
    mainProgram = "natspec";
  };
})
