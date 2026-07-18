{
  lib,
  stdenv,
  fetchurl,
  # buildInputs
  SDL2,
  adwaita-icon-theme,
  alsa-lib,
  cairo,
  # nativeBuildInputs
  cmake,
  # Linux only
  colord,
  colord-gtk,
  curl,
  desktop-file-utils,
  exiv2,
  gitUpdater,
  glib,
  glib-networking,
  gmic,
  graphicsmagick,
  # Darwin only
  gtk-mac-integration,
  gtk3,
  icu,
  intltool,
  isocodes,
  jasper,
  json-glib,
  lcms2,
  lensfun,
  lerc,
  libaom,
  libarchive,
  libavif,
  libdatrie,
  libepoxy,
  libexif,
  libgcrypt,
  libgpg-error,
  libgphoto2,
  libheif,
  libjpeg,
  libjxl,
  libpng,
  librsvg,
  libsecret,
  libselinux,
  libsepol,
  libsysprof-capture,
  libthai,
  libtiff,
  libwebp,
  libx11,
  libxdmcp,
  libxkbcommon,
  libxml2,
  libxtst,
  llvmPackages,
  lua5_4,
  ninja,
  ocl-icd,
  onnxruntime,
  openexr,
  openjpeg,
  osm-gps-map,
  pcre2,
  perl,
  pkg-config,
  portmidi,
  potrace,
  pugixml,
  saxon,
  sqlite,
  util-linux,
  versionCheckHook,
  wrapGAppsHook3,
  withAi ? false,
}:
let
  pugixml-shared = pugixml.override { shared = true; };
in
stdenv.mkDerivation rec {
  pname = "darktable";
  version = "5.6.0";

  src = fetchurl {
    url = "https://github.com/darktable-org/darktable/releases/download/release-${version}/darktable-${version}.tar.xz";
    hash = "sha256-FX1tOEevivyr54lERUeG9zqIbgilBLS9YRTCBl/gBuQ=";
  };

  postPatch = ''
    patchShebangs ./tools/generate_styles_string.sh
  '';

  nativeBuildInputs = [
    cmake
    desktop-file-utils
    intltool
    llvmPackages.llvm
    ninja
    perl
    pkg-config
    wrapGAppsHook3
    saxon # Use Saxon instead of libxslt to fix XSLT generate-id() consistency issues
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ llvmPackages.lld ];

  buildInputs = [
    SDL2
    adwaita-icon-theme
    cairo
    curl
    exiv2
    glib
    glib-networking
    gmic
    graphicsmagick
    gtk3
    icu
    isocodes
    jasper
    json-glib
    lcms2
    lensfun
    lerc
    libaom
    libavif
    libdatrie
    libepoxy
    libexif
    libgcrypt
    libgpg-error
    libgphoto2
    libheif
    libjpeg
    libjxl
    libpng
    librsvg
    libsecret
    libsysprof-capture
    libthai
    libtiff
    libwebp
    libxml2
    lua5_4
    openexr
    openjpeg
    osm-gps-map
    pcre2
    portmidi
    potrace
    pugixml-shared
    sqlite
  ]
  ++ lib.optionals withAi [
    libarchive
    onnxruntime
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    colord
    colord-gtk
    libselinux
    libsepol
    libx11
    libxdmcp
    libxkbcommon
    libxtst
    ocl-icd
    util-linux
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin gtk-mac-integration
  ++ lib.optional stdenv.cc.isClang llvmPackages.openmp;

  cmakeFlags = [
    "-DBUILD_USERMANUAL=False"
  ]
  ++ lib.optionals withAi [
    (lib.cmakeBool "USE_AI" true)
    (lib.cmakeBool "ONNXRUNTIME_OFFLINE" true)
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "-DUSE_COLORD=OFF"
    "-DUSE_KWALLET=OFF"
  ];

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    # Work around ld64's libc++ hardening issue.
    # TODO: Remove once #536365 reaches this branch.
    NIX_CFLAGS_LINK = "-fuse-ld=lld";
  };

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  # darktable changed its rpath handling in commit
  # 83c70b876af6484506901e6b381304ae0d073d3c and as a result the
  # binaries can't find libdarktable.so, so change LD_LIBRARY_PATH in
  # the wrappers:
  preFixup =
    let
      libPathEnvVar = if stdenv.hostPlatform.isDarwin then "DYLD_LIBRARY_PATH" else "LD_LIBRARY_PATH";
      libPathPrefix =
        "$out/lib/darktable"
        + lib.optionalString (withAi && stdenv.hostPlatform.isLinux) ":${lib.getLib onnxruntime}/lib"
        + lib.optionalString stdenv.hostPlatform.isLinux ":${ocl-icd}/lib";
    in
    ''
      for f in $out/share/darktable/kernels/*.cl; do
        sed -r "s|#include \"(.*)\"|#include \"$out/share/darktable/kernels/\1\"|g" -i "$f"
      done

      gappsWrapperArgs+=(
        --prefix ${libPathEnvVar} ":" "${libPathPrefix}"
      )
    '';

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "release-";
    url = "https://github.com/darktable-org/darktable.git";
  };

  meta = {
    description = "Virtual lighttable and darkroom for photographers";
    homepage = "https://www.darktable.org";
    changelog = "https://github.com/darktable-org/darktable/releases/tag/release-${version}";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      flosse
      mrVanDalo
      paperdigits
      freyacodes
    ];

    platforms = with lib.platforms; linux ++ darwin;
  };
}
