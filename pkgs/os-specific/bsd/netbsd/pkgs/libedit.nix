{
  compatIfNeeded,
  defaultMakeFlags,
  libcurses,
  libterminfo,
  mkDerivation,
}:

mkDerivation {
  postPatch = ''
    sed -i '1i #undef bool_t' $COMPONENT_PATH/el.h
    substituteInPlace $COMPONENT_PATH/config.h \
      --replace "#define HAVE_STRUCT_DIRENT_D_NAMLEN 1" ""
    substituteInPlace $COMPONENT_PATH/readline/Makefile --replace /usr/include "$out/include"
  '';

  buildInputs = [
    libterminfo
    libcurses
  ];

  propagatedBuildInputs = compatIfNeeded;
  makeFlags = defaultMakeFlags ++ [ "LIBDO.terminfo=${libterminfo}/lib" ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-D__noinline="
    "-D__scanflike(a,b)="
    "-D__va_list=va_list"
  ];

  SHLIBINSTALLDIR = "$(out)/lib";
  path = "lib/libedit";
}
