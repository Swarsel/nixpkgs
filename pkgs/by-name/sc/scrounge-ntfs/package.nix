{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "scrounge-ntfs";
  version = "0.9";

  src = fetchurl {
    url = "http://thewalter.net/stef/software/scrounge/scrounge-ntfs-${finalAttrs.version}.tar.gz";
    hash = "sha256-HYrMIMTRPmgAac/vaZ1jaUFchyAl5B0quxgHH0DHJ84=";
  };

  patches = [
    ./darwin.diff
  ];

  postPatch = ''
    substituteInPlace src/{list,ntfsx,scrounge}.c \
      --replace-fail "lseek64" "lseek"
  '';

  env.NIX_CFLAGS_COMPILE = "-D_FILE_OFFSET_BITS=64";

  meta = {
    description = "Data recovery program for NTFS file systems";
    homepage = "http://thewalter.net/stef/software/scrounge/";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "scrounge-ntfs";
  };
})
