{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  libnotify,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "batsignal";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "electrickite";
    repo = "batsignal";
    tag = finalAttrs.version;
    sha256 = "sha256-yngd2yP6XtRp8y8ZUd0NISdf8+8wJvpLogrQQMdB0lA=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libnotify
    glib
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-error=incompatible-pointer-types"
  ];

  installFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = {
    description = "Lightweight battery daemon written in C";
    homepage = "https://github.com/electrickite/batsignal";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ SlothOfAnarchy ];
    platforms = lib.platforms.linux;
    mainProgram = "batsignal";
  };
})
