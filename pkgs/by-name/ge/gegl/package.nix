{
  lib,
  stdenv,
  fetchurl,
  babl,
  bzip2,
  cairo,
  gettext,
  gexiv2,
  gi-docgen,
  gimp,
  glib,
  gobject-introspection,
  json-glib,
  lensfun,
  libjpeg,
  libnsgif,
  libpng,
  libraw,
  librsvg,
  libspiro,
  libwebp,
  llvmPackages,
  luajit,
  maxflow,
  meson,
  ninja,
  openexr,
  pango,
  pkg-config,
  poly2tri-c,
  poppler,
  suitesparse,
  vala,
  withLuaJIT ? lib.meta.availableOn stdenv.hostPlatform luajit,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gegl";
  version = "0.4.70";

  src = fetchurl {
    url = "https://download.gimp.org/pub/gegl/${lib.versions.majorMinor finalAttrs.version}/gegl-${finalAttrs.version}.tar.xz";
    hash = "sha256-R/UNnDrs03XetIwR6/6tUtFi5PwWKks9RGGCd/H67AI=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  postPatch = ''
    chmod +x tests/opencl/opencl_test.sh
    patchShebangs tests/ff-load-save/tests_ff_load_save.sh tests/opencl/opencl_test.sh tools/xml_insert.sh
  '';

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    gettext
    meson
    ninja
    vala
    gobject-introspection
    gi-docgen
  ];

  buildInputs = [
    libpng
    cairo
    libjpeg
    librsvg
    lensfun
    libspiro
    maxflow
    libnsgif
    pango
    poly2tri-c
    poppler
    bzip2
    libraw
    libwebp
    gexiv2
    openexr
    suitesparse
    vala
  ]
  ++ lib.optionals stdenv.cc.isClang [
    llvmPackages.openmp
  ]
  ++ lib.optionals withLuaJIT [
    luajit
  ];

  # for gegl-4.0.pc
  propagatedBuildInputs = [
    glib
    json-glib
    babl
  ];

  mesonFlags = [
    "-Dmrg=disabled" # not sure what that is
    "-Dsdl2=disabled"
    "-Dpygobject=disabled"
    "-Dlibav=disabled"
    "-Dlibv4l=disabled"
    "-Dlibv4l2=disabled"
    # Disabled due to multiple vulnerabilities, see
    # https://github.com/NixOS/nixpkgs/pull/73586
    "-Djasper=disabled"
  ]
  ++ lib.optionals (!withLuaJIT) [
    "-Dlua=disabled"
  ];

  # tests fail to connect to the com.apple.fonts daemon in sandboxed mode
  doCheck = !stdenv.hostPlatform.isDarwin;

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc" "$devdoc"
  '';

  outputBin = "dev";

  passthru = {
    tests = {
      inherit gimp;
    };
  };

  meta = {
    description = "Graph-based image processing framework";
    homepage = "https://www.gegl.org";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ jtojnar ];
    platforms = lib.platforms.unix;
  };
})
