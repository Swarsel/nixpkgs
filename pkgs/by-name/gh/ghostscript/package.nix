{
  lib,
  stdenv,
  fetchurl,
  autoconf,
  bash,
  buildPackages,
  callPackage,
  config,
  cups,
  expat,
  fetchpatch2,
  fixDarwinDylibNames,
  fontconfig,
  freetype,
  # for passthru.tests
  graphicsmagick,
  ijs,
  imagemagick,
  jbig2dec,
  lcms2,
  libice,
  libiconv,
  libjpeg,
  libpaper,
  libpng,
  libspectre,
  libtiff,
  libx11,
  libxext,
  libxt,
  lilypond,
  openjpeg,
  openssl,
  pkg-config,
  pstoedit,
  python3,
  zlib,
  cupsSupport ? config.ghostscript.cups or (!stdenv.hostPlatform.isDarwin),
  dynamicDrivers ? true,
  x11Support ? cupsSupport,
}:

let
  fonts = stdenv.mkDerivation {
    installPhase = ''
      mkdir "$out"
      mv -v * "$out/"
    '';

    name = "ghostscript-fonts";

    srcs = [
      (fetchurl {
        hash = "sha256-DrbzVhGfLkmyVjIQhS4X9X+dzFdV81Cmmkag1kGgxAE=";
        url = "mirror://sourceforge/gs-fonts/ghostscript-fonts-std-8.11.tar.gz";
      })
      (fetchurl {
        hash = "sha256-gUbMzEaZ/p2rhBRGvdFwOfR2nJA+zrVECRiLkgdUqrM=";
        url = "mirror://gnu/ghostscript/gnu-gs-fonts-other-6.0.tar.gz";
      })
      # ... add other fonts here
    ];
  };

in
stdenv.mkDerivation (finalAttrs: {
  pname = "ghostscript${lib.optionalString x11Support "-with-X"}";
  version = "10.07.1";

  src = fetchurl {
    url = "https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs${
      lib.replaceStrings [ "." ] [ "" ] finalAttrs.version
    }/ghostscript-${finalAttrs.version}.tar.xz";

    hash = "sha256-HNt2bejbjx5YnIF/CcWFXqX2XfyFQORlpprBTBhBYCU=";
  };

  outputs = [
    "out"
    "man"
    "doc"
    "fonts"
  ];

  patches = [
    ./urw-font-files.patch
    ./doc-no-ref.diff

    # Support SOURCE_DATE_EPOCH for reproducible builds
    (fetchpatch2 {
      hash = "sha256-XTKkFKzMR2QpcS1YqoxzJnyuGk/l/Y2jdevsmbMtCXA=";
      url = "https://salsa.debian.org/debian/ghostscript/-/raw/01e895fea033cc35054d1b68010de9818fa4a8fc/debian/patches/2010_add_build_timestamp_setting.patch";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    autoconf
    zlib
  ]
  ++ lib.optional cupsSupport cups
  ++ lib.optional stdenv.hostPlatform.isDarwin fixDarwinDylibNames;

  buildInputs = [
    zlib
    expat
    openssl
    libjpeg
    libpng
    libtiff
    freetype
    fontconfig
    libpaper
    jbig2dec
    libiconv
    ijs
    lcms2
    bash
    openjpeg
  ]
  ++ lib.optionals x11Support [
    libice
    libx11
    libxext
    libxt
  ]
  ++ lib.optional cupsSupport cups;

  configureFlags = [
    "CFLAGS=-std=gnu17"
    "--with-system-libtiff"
    "--without-tesseract"
  ]
  ++ lib.optionals dynamicDrivers [
    "--enable-dynamic"
    "--disable-hidden-visibility"
  ]
  ++ lib.optionals x11Support [
    "--with-x"
  ]
  ++ lib.optionals cupsSupport [
    "--enable-cups"
  ];

  # don't build/install statically linked bin/gs
  buildFlags = [
    "so"
  ]
  # without -headerpad, the following error occurs on Darwin when compiling with X11 support (as of 10.02.0)
  # error: install_name_tool: changing install names or rpaths can't be redone for: [...]libgs.dylib.10 (the program must be relinked, and you may need to use -headerpad or -headerpad_max_install_names)
  ++ lib.optional (x11Support && stdenv.hostPlatform.isDarwin) "LDFLAGS=-headerpad_max_install_names";

  preConfigure = ''
    # https://ghostscript.com/doc/current/Make.htm
    export CCAUX=$CC_FOR_BUILD
    ${lib.optionalString cupsSupport ''export CUPSCONFIG="${cups.dev}/bin/cups-config"''}

    rm -rf jpeg libpng zlib jasper expat tiff lcms2mt jbig2dec freetype cups/libs ijs openjpeg

    sed "s@if ( test -f \$(INCLUDE)[^ ]* )@if ( true )@; s@INCLUDE=/usr/include@INCLUDE=/no-such-path@" -i base/unix-aux.mak
    sed "s@^ZLIBDIR=.*@ZLIBDIR=${zlib.dev}/include@" -i configure.ac

    # Sidestep a bug in autoconf-2.69 that sets the compiler for all checks to
    # $CXX after the part for the vendored copy of tesseract.
    # `--without-tesseract` is already passed to the outer ./configure, here we
    # make sure it is also passed to its recursive invocation for buildPlatform
    # checks when cross-compiling.
    substituteInPlace configure.ac \
      --replace-fail "--without-x" "--without-x --without-tesseract"

    autoconf
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    export DARWIN_LDFLAGS_SO_PREFIX=$out/lib/
  '';

  # make check does nothing useful
  doCheck = false;

  postInstall = ''
    ln -s gsc "$out"/bin/gs

    cp -r Resource "$out/share/ghostscript/${finalAttrs.version}"

    mkdir -p $fonts/share/fonts
    cp -rv ${fonts}/* "$fonts/share/fonts/"
    ln -s "$fonts/share/fonts" "$out/share/ghostscript/fonts"
  '';

  # validate dynamic linkage
  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/gs --version
    $out/bin/gsx --version
    pushd examples
    for f in *.{ps,eps,pdf}; do
      echo "Rendering $f"
      $out/bin/gs \
        -dNOPAUSE \
        -dBATCH \
        -sDEVICE=bitcmyk \
        -sOutputFile=/dev/null \
        -r600 \
        -dBufferSpace=100000 \
        $f
    done
    popd # examples

    runHook postInstallCheck
  '';

  depsBuildBuild = [
    buildPackages.stdenv.cc
  ];

  enableParallelBuilding = true;
  installTargets = [ "soinstall" ];

  passthru.tests = {
    inherit
      graphicsmagick
      imagemagick
      libspectre
      lilypond
      pstoedit
      ;

    inherit (python3.pkgs) matplotlib;
    test-corpus-render = callPackage ./test-corpus-render.nix { };
  };

  meta = {
    description = "PostScript interpreter (mainline version)";

    longDescription = ''
      Ghostscript is the name of a set of tools that provides (i) an
      interpreter for the PostScript language and the PDF file format,
      (ii) a set of C procedures (the Ghostscript library) that
      implement the graphics capabilities that appear as primitive
      operations in the PostScript language, and (iii) a wide variety
      of output drivers for various file formats and printers.
    '';

    homepage = "https://www.ghostscript.com/";
    changelog = "https://ghostscript.readthedocs.io/en/gs${finalAttrs.version}/News.html";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ tobim ];
    platforms = lib.platforms.all;
    mainProgram = "gs";
  };
})
