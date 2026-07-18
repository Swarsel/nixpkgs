{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  bash,
  bison,
  buildPackages,
  cairo,
  # for passthru.tests
  exiv2,
  expat,
  flex,
  fltk,
  fontconfig,
  gd,
  graphicsmagick,
  gts,
  libjpeg,
  libpng,
  libtool,
  libxrender,
  makeWrapper,
  pango,
  pkg-config,
  python3,
  runCommand,
  withQuartz ? false,
  withXorg ? true,
}:

let
  inherit (lib)
    optional
    optionals
    optionalString
    optionalAttrs
    ;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "graphviz";
  version = "14.1.2";

  src = fetchFromGitLab {
    owner = "graphviz";
    repo = "graphviz";
    tag = finalAttrs.version;
    hash = "sha256-LkyiKl0ulS9ujEdVLfyeoc4CtjITd6CAc35IUtlHSfw=";
  };

  # Invoke `dot -c` even while cross compiling else lib/graphviz/config6 will not load at runtime.
  postPatch = ''
    substituteInPlace cmd/dot/Makefile.am --replace-fail \
      'if test "x$(DESTDIR)" = "x" -a "x$(build)" = "x$(host)"; then if test -x $(bindir)/dot$(EXEEXT); then if test -x /sbin/ldconfig; then /sbin/ldconfig 2>/dev/null; fi; cd $(bindir); ./dot$(EXEEXT) -c; else cd $(bindir); ./dot_static$(EXEEXT) -c; fi; fi' \
      '${lib.optionalString (stdenv.hostPlatform.emulatorAvailable buildPackages) ''
        if test -x $(bindir)/dot$(EXEEXT); then \
          cd $(bindir); ${stdenv.hostPlatform.emulator buildPackages} ./dot$(EXEEXT) -c; \
        else \
          cd $(bindir); ${stdenv.hostPlatform.emulator buildPackages} ./dot_static$(EXEEXT) -c; \
        fi
      ''}'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    makeWrapper
    pkg-config
    python3
    bison
    flex
  ];

  buildInputs = [
    libpng
    libjpeg
    expat
    fontconfig
    gd
    gts
    pango
    bash
  ]
  ++ optionals withXorg [ libxrender ];

  configureFlags = [
    "--with-ltdl-lib=${libtool.lib}/lib"
    "--with-ltdl-include=${libtool}/include"
    (lib.withFeature withXorg "x")
  ]
  ++ optional withQuartz "--with-quartz";

  env = optionalAttrs (withXorg && stdenv.hostPlatform.isDarwin) {
    CPPFLAGS = "-I${cairo.dev}/include/cairo";
  };

  doCheck = false; # fails with "Graphviz test suite requires ksh93" which is not in nixpkgs

  postFixup = optionalString withXorg ''
    substituteInPlace $out/bin/vimdot \
      --replace-warn '"/usr/bin/vi"' '"$(command -v vi)"' \
      --replace-warn '"/usr/bin/vim"' '"$(command -v vim)"' \
      --replace-warn /usr/bin/vimdot $out/bin/vimdot

    wrapProgram $out/bin/vimdot --prefix PATH : "$out/bin"
  '';

  enableParallelBuilding = true;
  hardeningDisable = [ "fortify" ];

  preAutoreconf = ''
    ./autogen.sh
  '';

  passthru.tests = {
    inherit (python3.pkgs)
      graphviz
      pydot
      pygraphviz
      xdot
      ;

    inherit
      exiv2
      fltk
      graphicsmagick
      ;

    dot-can-load-plugins =
      runCommand "dot-can-load-plugins"
        {
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          dot -P -o $out
        '';
  };

  meta = {
    description = "Graph visualization tools";
    homepage = "https://graphviz.org";
    changelog = "https://gitlab.com/graphviz/graphviz/-/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.epl10;

    maintainers = with lib.maintainers; [
      bjornfor
      raskin
    ];

    platforms = lib.platforms.unix;
  };
})
