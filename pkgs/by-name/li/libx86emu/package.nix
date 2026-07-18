{
  lib,
  stdenv,
  fetchFromGitHub,
  perl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libx86emu";
  version = "3.7";

  src = fetchFromGitHub {
    owner = "wfeldt";
    repo = "libx86emu";
    rev = finalAttrs.version;
    sha256 = "sha256-ilAmGlkMeuG0FlygMdE3NreFPJJF6g/26C8C5grvjrk=";
  };

  nativeBuildInputs = [ perl ];

  buildFlags = [
    "shared"
    "CC=${stdenv.cc.targetPrefix}cc"
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-implicit-function-declaration";
  enableParallelBuilding = true;

  installFlags = [
    "DESTDIR=$(out)"
    "LIBDIR=/lib"
  ];

  patchPhase = ''
    # VERSION is usually generated using Git
    echo "${finalAttrs.version}" > VERSION
    substituteInPlace Makefile --replace "/usr" "/"
  '';

  postUnpack = "rm $sourceRoot/git2log";

  meta = {
    description = "x86 emulation library";
    homepage = "https://github.com/wfeldt/libx86emu";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ bobvanderlinden ];
    platforms = lib.platforms.linux;
  };
})
