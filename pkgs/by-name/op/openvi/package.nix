{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  ncurses,
  perl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "openvi";
  version = "7.7.32";

  src = fetchFromGitHub {
    owner = "johnsonjh";
    repo = "OpenVi";
    tag = finalAttrs.version;
    hash = "sha256-kLULaKEefMpNLANnVdWAZeH+2KY5gEWGce6vJ/R7HAI=";
  };

  patches = [
    # fix build w/ glibc 2.42 (https://github.com/johnsonjh/OpenVi/pull/46)
    (fetchpatch {
      excludes = [ "ChangeLog" ];
      hash = "sha256-GOair/unxROEPvtTekGuKacKwOctPyoRdvilqdVLjrY=";
      url = "https://github.com/johnsonjh/OpenVi/commit/67c76961f512bfe95616fe25b32928db0aab9326.patch";
    })
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    perl
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    ncurses
  ];

  makeFlags = [
    "PREFIX=$(out)"
    # command -p will yield command not found error
    "PAWK=awk"
    # silently fail the chown command
    "IUSGR=$(USER)"
  ];

  # Don't include ncurses header, but link against ncurses
  # openvi requires GNU ncurses symbols, but ncurses headers
  # is incompatible with macOS wchar.h, resulting in
  # "error: expected function body after function declarator"
  env.NIX_LDFLAGS = lib.optionalString stdenv.hostPlatform.isDarwin "-L${lib.getLib ncurses}/lib -lncursesw";
  enableParallelBuilding = true;

  meta = {
    description = "Portable OpenBSD vi for UNIX systems";
    homepage = "https://github.com/johnsonjh/OpenVi";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.unix;
    mainProgram = "ovi";
  };
})
