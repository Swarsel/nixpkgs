{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "erfa";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "liberfa";
    repo = "erfa";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-NtHYgiN5mo3kWC2H+5TUDbU1nFrwuhNyOIhg2jZbssM=";
  };

  nativeBuildInputs = [ autoreconfHook ];
  configureFlags = [ "--enable-shared" ];

  meta = {
    description = "Essential Routines for Fundamental Astronomy";
    homepage = "https://github.com/liberfa/erfa";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ mir06 ];
  };
})
