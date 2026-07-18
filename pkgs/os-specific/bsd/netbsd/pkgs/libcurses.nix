{
  lib,
  stdenv,
  compatIfNeeded,
  defaultMakeFlags,
  libterminfo,
  mkDerivation,
}:

mkDerivation {
  postPatch = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    substituteInPlace $COMPONENT_PATH/printw.c \
      --replace "funopen(win, NULL, __winwrite, NULL, NULL)" NULL \
      --replace "__strong_alias(vwprintw, vw_printw)" 'extern int vwprintw(WINDOW*, const char*, va_list) __attribute__ ((alias ("vw_printw")));'
    substituteInPlace $COMPONENT_PATH/scanw.c \
      --replace "__strong_alias(vwscanw, vw_scanw)" 'extern int vwscanw(WINDOW*, const char*, va_list) __attribute__ ((alias ("vw_scanw")));'
  '';

  buildInputs = [ libterminfo ];
  propagatedBuildInputs = compatIfNeeded;
  makeFlags = defaultMakeFlags ++ [ "LIBDO.terminfo=${libterminfo}/lib" ];

  env.NIX_CFLAGS_COMPILE = toString (
    [
      "-D__scanflike(a,b)="
      "-D__va_list=va_list"
      "-D__warn_references(a,b)="
    ]
    ++ lib.optional stdenv.hostPlatform.isDarwin "-D__strong_alias(a,b)="
  );

  MKDOC = "no"; # missing vfontedpr
  path = "lib/libcurses";
}
