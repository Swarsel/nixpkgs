{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  # Optional dependencies
  cfitsio,
  cgif,
  # Native build inputs
  docbook-xsl-nons,
  # Build inputs
  expat,
  fftw,
  gi-docgen,
  glib,
  gobject-introspection,
  imagemagick,
  # meta
  immich,
  lcms2,
  libarchive,
  libexif,
  libheif,
  libhwy,
  libimagequant,
  libjpeg,
  libjxl,
  libpng,
  librsvg,
  libtiff,
  libwebp,
  libxml2,
  matio,
  meson,
  ninja,
  nix-update-script,
  openexr,
  openjpeg,
  openslide,
  pango,
  pkg-config,
  poppler,
  python3,
  # passthru
  testers,
  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vips";
  version = "8.17.3";

  src = fetchFromGitHub {
    owner = "libvips";
    repo = "libvips";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yxjfkb2R3JPHbz0vCG4hkW9Davoc9MUPHL9Cqc+Ik0Y=";

    # Remove unicode file names which leads to different checksums on HFS+
    # vs. other filesystems because of unicode normalisation.
    postFetch = ''
      rm -r $out/test/test-suite/images/
    '';
  };

  outputs = [
    "bin"
    "out"
    "man"
    "dev"
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin && !stdenv.hostPlatform.isFreeBSD) [ "devdoc" ];

  postPatch = ''
    patchShebangs .
  '';

  nativeBuildInputs = [
    docbook-xsl-nons
    gobject-introspection
    meson
    ninja
    pkg-config
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin && !stdenv.hostPlatform.isFreeBSD) [
    gi-docgen
  ];

  buildInputs = [
    glib
    libxml2
    expat
    (python3.withPackages (p: [ p.pycairo ]))

    # Optional dependencies
    cfitsio
    cgif
    fftw
    imagemagick
    lcms2
    libarchive
    libexif
    libheif
    libhwy
    libimagequant
    libjpeg
    libjxl
    librsvg
    libpng
    libtiff
    libwebp
    matio
    openexr
    openjpeg
    openslide
    pango
    poppler
  ];

  # Required by .pc file
  propagatedBuildInputs = [
    glib
  ];

  mesonFlags = [
    (lib.mesonEnable "pdfium" false)
    (lib.mesonEnable "nifti" false)
    (lib.mesonEnable "spng" false) # we want to use libpng
    (lib.mesonEnable "introspection" withIntrospection)
  ]
  ++ lib.optional (!stdenv.hostPlatform.isDarwin && !stdenv.hostPlatform.isFreeBSD) (
    lib.mesonBool "docs" true
  )
  ++ lib.optional (imagemagick == null) (lib.mesonEnable "magick" false);

  postFixup = ''
    moveToOutput "share/doc" "$devdoc"
  '';

  passthru = {
    tests = {
      version = testers.testVersion {
        command = "vips --version";
        package = finalAttrs.finalPackage;
      };

      pkg-config = testers.hasPkgConfigModules {
        package = finalAttrs.finalPackage;
      };
    };

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "^v([0-9.]+)$"
      ];
    };
  };

  meta = {
    inherit (immich.meta) maintainers;
    description = "Image processing system for large images";
    homepage = "https://www.libvips.org/";
    changelog = "https://github.com/libvips/libvips/blob/${finalAttrs.src.rev}/ChangeLog";
    license = lib.licenses.lgpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "vips";

    pkgConfigModules = [
      "vips"
      "vips-cpp"
    ];
  };
})
