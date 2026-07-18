{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchDebianPatch,
  fetchpatch,
  ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hexcurse";
  version = "1.60.0";

  src = fetchFromGitHub {
    owner = "LonnyGomes";
    repo = "hexcurse";
    rev = "v${finalAttrs.version}";
    sha256 = "17ckkxfzbqvvfdnh10if4aqdcq98q3vl6dn1v6f4lhr4ifnyjdlk";
  };

  patches = [
    # gcc7 compat
    (fetchpatch {
      sha256 = "0h8345blmc401c6bivf0imn4cwii67264yrzxg821r46wrnfvyi2";
      url = "https://github.com/LonnyGomes/hexcurse/commit/d808cb7067d1df067f8b707fabbfaf9f8931484c.patch";
    })
    # gcc7 compat
    (fetchpatch {
      sha256 = "0v6gbp6pjpmnzswlf6d97aywiy015g3kcmfrrkspsbb7lh1y3nix";
      url = "https://github.com/LonnyGomes/hexcurse/commit/716b5d58ac859cc240b8ccb9cbd79ace3e0593c1.patch";
    })

    # Fix pending upstream inclusion for gcc10 -fno-common compatibility:
    #  https://github.com/LonnyGomes/hexcurse/pull/28
    (fetchpatch {
      name = "fno-common.patch";
      sha256 = "1awsyxys4pd3gkkgyckgjg3njgqy07223kcmnpfdkidh2xb0s360";
      url = "https://github.com/LonnyGomes/hexcurse/commit/9cf7c9dcd012656df949d06f2986b57db3a72bdc.patch";
    })

    # Fix pending upstream inclusion for ncurses-6.3 support:
    #  https://github.com/LonnyGomes/hexcurse/pull/40
    (fetchpatch {
      name = "ncurses-6.3.patch";
      sha256 = "19674zhhp7gc097kl4bxvi0gblq6jzjy8cw8961svbq5y3hv1v5y";
      url = "https://github.com/LonnyGomes/hexcurse/commit/cb70d4a93a46102f488f471fad31a7cfc9fec025.patch";
    })

    # Fix build with GCC 15 (old-style function definitions)
    (fetchDebianPatch {
      pname = "hexcurse";
      version = "1.60.0";
      debianRevision = "1";
      hash = "sha256-nWwYjI18fsJ9LSby6OJoJ0QXENgyVbUY3LpEYWoCBkI=";
      patch = "gcc-15.patch";
    })
  ];

  buildInputs = [ ncurses ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-error=stringop-overflow"
    "-Wno-error=stringop-truncation"
  ];

  meta = {
    description = "ncurses-based console hexeditor written in C";
    homepage = "https://github.com/LonnyGomes/hexcurse";
    license = lib.licenses.gpl2;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "hexcurse";
  };
})
