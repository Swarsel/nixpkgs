{
  lib,
  stdenv,
  fetchFromGitHub,
  bzip2,
  coreutils,
  curl,
  djvulibre,
  fftw,
  fontconfig,
  freetype,
  ghostscript,
  lcms2,
  libheif,
  libjpeg,
  libjxl,
  liblqr1,
  libpng,
  libraqm,
  libraw,
  librsvg,
  libtiff,
  libtool,
  libultrahdr,
  libwebp,
  libx11,
  libxml2,
  libxt,
  nix-update-script,
  nixos-icons,
  openexr,
  openjpeg,
  pango,
  perlPackages,
  pkg-config,
  potrace,
  python3,
  testers,
  versionCheckHook,
  zlib,
  bzip2Support ? true,
  djvulibreSupport ? true,
  fftwSupport ? true,
  fontconfigSupport ? true,
  freetypeSupport ? true,
  ghostscriptSupport ? false,
  lcms2Support ? true,
  libX11Support ? !stdenv.hostPlatform.isMinGW,
  libXtSupport ? !stdenv.hostPlatform.isMinGW,
  libheifSupport ? true,
  libjpegSupport ? true,
  libjxlSupport ? true,
  liblqr1Support ? true,
  libpngSupport ? true,
  libraqmSupport ? true,
  librawSupport ? true,
  librsvgSupport ? !stdenv.hostPlatform.isMinGW,
  libtiffSupport ? true,
  libultrahdrSupport ? lib.meta.availableOn stdenv.hostPlatform libultrahdr,
  libwebpSupport ? !stdenv.hostPlatform.isMinGW,
  libxml2Support ? true,
  openexrSupport ? !stdenv.hostPlatform.isMinGW,
  openjpegSupport ? !stdenv.hostPlatform.isMinGW,
  zlibSupport ? true,
}:

assert libXtSupport -> libX11Support;
assert libraqmSupport -> freetypeSupport;

let
  arch =
    if stdenv.hostPlatform.system == "i686-linux" then
      "i686"
    else if
      stdenv.hostPlatform.system == "x86_64-linux" || stdenv.hostPlatform.system == "x86_64-darwin"
    then
      "x86-64"
    else if stdenv.hostPlatform.system == "armv7l-linux" then
      "armv7l"
    else if
      stdenv.hostPlatform.system == "aarch64-linux" || stdenv.hostPlatform.system == "aarch64-darwin"
    then
      "aarch64"
    else if stdenv.hostPlatform.system == "powerpc64le-linux" then
      "ppc64le"
    else
      null;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "imagemagick";
  version = "7.1.2-27";

  src = fetchFromGitHub {
    owner = "ImageMagick";
    repo = "ImageMagick";
    tag = finalAttrs.version;
    hash = "sha256-QCC2CO2zkhwlEWymwF739uSNuS7QCqqGIJnF/LtYzVc=";
  };

  outputs = [
    "out"
    "dev"
    "doc"
  ]; # bin/ isn't really big

  nativeBuildInputs = [
    pkg-config
    libtool
  ];

  buildInputs = [
    potrace
  ]
  ++ lib.optional zlibSupport zlib
  ++ lib.optional fontconfigSupport fontconfig
  ++ lib.optional ghostscriptSupport ghostscript
  ++ lib.optional liblqr1Support liblqr1
  ++ lib.optional libpngSupport libpng
  ++ lib.optional libraqmSupport libraqm
  ++ lib.optional librawSupport libraw
  ++ lib.optional libtiffSupport libtiff
  ++ lib.optional libultrahdrSupport libultrahdr
  ++ lib.optional libxml2Support libxml2
  ++ lib.optional libheifSupport libheif
  ++ lib.optional djvulibreSupport djvulibre
  ++ lib.optional libjxlSupport libjxl
  ++ lib.optional openexrSupport openexr
  ++ lib.optionals librsvgSupport [
    librsvg
    pango
  ]
  ++ lib.optional openjpegSupport openjpeg;

  propagatedBuildInputs = [
    curl
  ]
  ++ lib.optional bzip2Support bzip2
  ++ lib.optional freetypeSupport freetype
  ++ lib.optional libjpegSupport libjpeg
  ++ lib.optional lcms2Support lcms2
  ++ lib.optional libX11Support libx11
  ++ lib.optional libXtSupport libxt
  ++ lib.optional libwebpSupport libwebp
  ++ lib.optional fftwSupport fftw;

  configureFlags = [
    # specify delegates explicitly otherwise `convert` will invoke the build
    # coreutils for filetypes it doesn't natively support.
    "MVDelegate=${lib.getExe' coreutils "mv"}"
    "RMDelegate=${lib.getExe' coreutils "rm"}"
    "--with-frozenpaths"
    (lib.withFeatureAs (arch != null) "gcc-arch" arch)
    (lib.withFeature librsvgSupport "rsvg")
    (lib.withFeature librsvgSupport "pango")
    (lib.withFeature liblqr1Support "lqr")
    (lib.withFeature libjxlSupport "jxl")
    (lib.withFeature libultrahdrSupport "uhdr")
    (lib.withFeatureAs ghostscriptSupport "gs-font-dir" "${ghostscript.fonts}/share/fonts")
    (lib.withFeature ghostscriptSupport "gslib")
    (lib.withFeature fftwSupport "fftw")
  ]
  ++ lib.optionals stdenv.hostPlatform.isMinGW [
    # due to libxml2 being without DLLs ATM
    "--enable-static"
    "--disable-shared"
  ];

  postInstall = ''
    (cd "$dev/include" && ln -s ImageMagick* ImageMagick)
    # Q16HDRI = 16 bit quantum depth with HDRI support, and is the default ImageMagick configuration
    # If the default is changed, or the derivation is modified to use a different configuration
    # this will need to be changed below.
    moveToOutput "bin/*-config" "$dev"
    moveToOutput "lib/ImageMagick-*/config-Q16HDRI" "$dev" # includes configure params
    configDestination=($out/share/ImageMagick-*)
    grep -v '/nix/store' $dev/lib/ImageMagick-*/config-Q16HDRI/configure.xml > $configDestination/configure.xml
    for file in "$dev"/bin/*-config; do
      substituteInPlace "$file" --replace-fail "$PKG_CONFIG" \
        "PKG_CONFIG_PATH='$dev/lib/pkgconfig' '$(command -v $PKG_CONFIG)'"
    done
  ''
  + lib.optionalString ghostscriptSupport ''
    for la in $out/lib/*.la; do
      sed 's|-lgs|-L${lib.getLib ghostscript}/lib -lgs|' -i $la
    done
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  enableParallelBuilding = true;
  outputMan = "out"; # it's tiny

  passthru.tests = {
    inherit nixos-icons;
    inherit (perlPackages) ImageMagick;
    inherit (python3.pkgs) img2pdf willow;

    pkg-config = testers.hasPkgConfigModules {
      version = lib.head (lib.splitString "-" finalAttrs.version);
      package = finalAttrs.finalPackage;
    };
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Software suite to create, edit, compose, or convert bitmap images";
    homepage = "http://www.imagemagick.org/";
    changelog = "https://github.com/ImageMagick/Website/blob/main/docs/changelog/index.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      dotlambda
      rhendric
      faukah
    ];

    platforms = lib.platforms.unix;
    mainProgram = "magick";

    pkgConfigModules = [
      "ImageMagick"
      "MagickWand"
    ];
  };
})
