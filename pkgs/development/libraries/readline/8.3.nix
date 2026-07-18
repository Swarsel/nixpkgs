{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  ncurses,
  termcap,
  updateAutotoolsGnuConfigScriptsHook,
  curses-library ? if stdenv.hostPlatform.isWindows then termcap else ncurses,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "readline";
  version = "8.3p${toString (builtins.length finalAttrs.upstreamPatches)}";

  src = fetchurl {
    url = "mirror://gnu/readline/readline-${finalAttrs.meta.branch}.tar.gz";
    hash = "sha256-/lODIERngozUle6NHTwDen66E4nCK8agQfYnl2+QYcw=";
  };

  outputs = [
    "out"
    "dev"
    "man"
    "doc"
    "info"
  ];

  patches =
    lib.optionals (curses-library.pname == "ncurses") [
      ./link-against-ncurses.patch
    ]
    ++ [
      ./no-arch_only-8.2.patch
    ]
    ++ finalAttrs.upstreamPatches
    ++ lib.optionals stdenv.hostPlatform.isWindows [
      (fetchpatch {
        hash = "sha256-sFK6EJrSNl0KLWqFv5zBXaQRuiQoYIZVoZfa8BZqfKA=";
        name = "0001-sigwinch.patch";
        stripLen = 1;
        url = "https://github.com/msys2/MINGW-packages/raw/90e7536e3b9c3af55c336d929cfcc32468b2f135/mingw-w64-readline/0001-sigwinch.patch";
      })
      (fetchpatch {
        hash = "sha256-KXI85yKedS/eQ3W0a9rhG9zzN/IQT58qhPdWC2kU0Kw=";
        name = "0002-event-hook.patch";
        stripLen = 1;
        url = "https://github.com/msys2/MINGW-packages/raw/13d7fe6618496d509bce96e1852e943096cba6fb/mingw-w64-readline/0002-event-hook.patch";
      })
      (fetchpatch {
        hash = "sha256-+z2ak32RnDIlGbz1RwQAf4r9Scn/C3lNyEpFB5rQ5s8=";
        name = "0003-no-winsize.patch";
        stripLen = 1;
        url = "https://github.com/msys2/MINGW-packages/raw/13d7fe6618496d509bce96e1852e943096cba6fb/mingw-w64-readline/0003-no-winsize.patch";
      })
      (fetchpatch {
        hash = "sha256-dk4343KP4EWXdRRCs8GRQlBgJFgu1rd79RfjwFD/nJc=";
        name = "0004-locale.patch";
        stripLen = 1;
        url = "https://github.com/msys2/MINGW-packages/raw/f768c4b74708bb397a77e3374cc1e9e6ef647f20/mingw-w64-readline/0004-locale.patch";
      })
    ];

  strictDeps = true;
  nativeBuildInputs = [ updateAutotoolsGnuConfigScriptsHook ];
  propagatedBuildInputs = [ curses-library ];

  # Make mingw-w64 provide a dummy alarm() function
  #
  # Method borrowed from
  # https://github.com/msys2/MINGW-packages/commit/35830ab27e5ed35c2a8d486961ab607109f5af50
  env = lib.optionalAttrs stdenv.hostPlatform.isMinGW {
    CFLAGS = toString [
      "-D__USE_MINGW_ALARM"
      "-D_POSIX"
    ];
  };

  # This install error is caused by a very old libtool. We can't autoreconfHook this package,
  # so this is the best we've got!
  postInstall = lib.optionalString stdenv.hostPlatform.isOpenBSD ''
    ln -s $out/lib/libhistory.so* $out/lib/libhistory.so
    ln -s $out/lib/libreadline.so* $out/lib/libreadline.so
  '';

  patchFlags = [ "-p0" ];

  upstreamPatches = (
    let
      patch =
        nr: sha256:
        fetchurl {
          inherit sha256;
          url = "mirror://gnu/readline/readline-${finalAttrs.meta.branch}-patches/readline83-${nr}";
        };
    in
    import ./readline-8.3-patches.nix patch
  );

  meta = {
    description = "Library for interactive line editing";

    longDescription = ''
      The GNU Readline library provides a set of functions for use by
      applications that allow users to edit command lines as they are
      typed in.  Both Emacs and vi editing modes are available.  The
      Readline library includes additional functions to maintain a
      list of previously-entered command lines, to recall and perhaps
      reedit those lines, and perform csh-like history expansion on
      previous commands.

      The history facilities are also placed into a separate library,
      the History library, as part of the build process.  The History
      library may be used without Readline in applications which
      desire its capabilities.
    '';

    homepage = "https://savannah.gnu.org/projects/readline/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix ++ lib.platforms.windows;
    branch = "8.3";
  };
})
