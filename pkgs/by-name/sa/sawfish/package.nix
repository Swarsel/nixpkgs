{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gdk-pixbuf-xlib,
  gettext,
  gtk2-x11,
  libice,
  librep,
  libsm,
  libxcrypt,
  libxinerama,
  libxrandr,
  libxtst,
  makeWrapper,
  pango,
  pkg-config,
  rep-gtk,
  texinfo,
  versionCheckHook,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sawfish";
  version = "1.13.0";

  src = fetchFromGitHub {
    owner = "SawfishWM";
    repo = "sawfish";
    tag = "sawfish-${finalAttrs.version}";
    hash = "sha256-4hxws3afDN9RjO9JCEjEgG4/g6bSycrmiJzRoyNnl3s=";
  };

  postPatch = ''
    sed -e 's|REP_DL_LOAD_PATH=|REP_DL_LOAD_PATH=$(REP_DL_LOAD_PATH):|g' -i Makedefs.in
    sed -e 's|$(repexecdir)|$(libdir)/rep|g' -i src/Makefile.in
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    gettext
    librep
    makeWrapper
    pkg-config
    texinfo
    which
  ];

  buildInputs = [
    gdk-pixbuf-xlib
    gtk2-x11
    libice
    libsm
    libxcrypt
    libxinerama
    libxrandr
    libxtst
    librep
    pango
    rep-gtk
  ];

  # fixes:
  # sawfish.h:52:13: error: 'bool' cannot be defined via 'typedef'
  env.NIX_CFLAGS_COMPILE = "-std=gnu17";

  postInstall = ''
    for file in $out/lib/sawfish/sawfish-menu \
             $out/bin/sawfish-about \
             $out/bin/sawfish-client \
             $out/bin/sawfish-config \
             $out/bin/sawfish; do
      wrapProgram $file \
        --prefix REP_DL_LOAD_PATH : "$out/lib/rep" \
        --set REP_LOAD_PATH "$out/share/sawfish/lisp"
    done
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  enableParallelBuilding = true;
  versionCheckProgram = "${placeholder "out"}/bin/${finalAttrs.meta.mainProgram}";

  meta = {
    description = "Extensible, Lisp-based window manager";

    longDescription = ''
      Sawfish is an extensible window manager using a Lisp-based scripting
      language. Its policy is very minimal compared to most window managers. Its
      aim is simply to manage windows in the most flexible and attractive manner
      possible. All high-level WM functions are implemented in Lisp for future
      extensibility or redefinition.
    '';

    homepage = "http://sawfish.tuxfamily.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "sawfish";
  };
})
