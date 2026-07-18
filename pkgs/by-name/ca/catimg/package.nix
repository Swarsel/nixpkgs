{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "catimg";
  version = "2.8.0";

  src = fetchFromGitHub {
    owner = "posva";
    repo = "catimg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TkUrDVg/EJQ3cAWosRDJ09pmOB0NANW7c/MFyH//Iok=";
  };

  nativeBuildInputs = [ cmake ];

  env = lib.optionalAttrs (stdenv.hostPlatform.libc == "glibc") {
    CFLAGS = "-D_DEFAULT_SOURCE";
  };

  meta = {
    description = "Insanely fast image printing in your terminal";
    homepage = "https://github.com/posva/catimg";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ryantm ];
    platforms = lib.platforms.unix;
    mainProgram = "catimg";
  };

})
