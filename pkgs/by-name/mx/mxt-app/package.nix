{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libtool,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mxt-app";
  version = "1.46";

  src = fetchFromGitHub {
    owner = "atmel-maxtouch";
    repo = "mxt-app";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-SeP48xdZ43dL28tg7mo8SmObUt3R+8oyETst6yKkhnU=";
  };

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ libtool ];
  hardeningDisable = [ "fortify" ];

  meta = {
    description = "Command line utility for Atmel maXTouch devices";
    homepage = "https://github.com/atmel-maxtouch/mxt-app";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "mxt-app";
  };
})
