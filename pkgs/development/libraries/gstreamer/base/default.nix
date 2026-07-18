{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  apple-sdk_gstreamer,
  buildPackages,
  cdparanoia,
  directoryListingUpdater,
  gettext,
  glib,
  gobject-introspection,
  graphene,
  gstreamer,
  hotdoc,
  isocodes,
  libGL,
  libdrm,
  libintl,
  libjpeg,
  libopus,
  libpng,
  libtheora,
  libxext,
  libxi,
  libxv,
  # TODO: Clean up on `staging`
  llvmPackages,
  meson,
  ninja,
  orc,
  pango,
  pkg-config,
  python3,
  testers,
  tremor, # provides 'virbisidec'
  wayland,
  wayland-protocols,
  wayland-scanner,
  enableAlsa ? stdenv.hostPlatform.isLinux,
  enableCdparanoia ? (!stdenv.hostPlatform.isDarwin),
  enableCocoa ? stdenv.hostPlatform.isDarwin,
  # Checks meson.is_cross_build(), so even canExecute isn't enough.
  enableDocumentation ? stdenv.hostPlatform == stdenv.buildPlatform,
  enableGl ? (enableX11 || enableWayland || enableCocoa),
  enableWayland ? stdenv.hostPlatform.isLinux,
  enableX11 ? stdenv.hostPlatform.isLinux,
  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gst-plugins-base";
  version = "1.28.4";

  src = fetchurl {
    url = "https://gstreamer.freedesktop.org/src/gst-plugins-base/gst-plugins-base-${finalAttrs.version}.tar.xz";
    hash = "sha256-qJiv1XZhcrAEnmeBVY4GiQmL+HudgrhGxlLlccAdYNg=";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    patchShebangs \
      scripts/meson-pkg-config-file-fixup.py \
      scripts/extract-release-date-from-doap-file.py
  '';

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
    gettext
    orc
    glib
    gstreamer
  ]
  ++ lib.optionals withIntrospection [
    gobject-introspection
  ]
  ++ lib.optionals enableDocumentation [
    hotdoc
  ]
  ++ lib.optionals enableWayland [
    wayland-scanner
  ]
  # TODO: Clean up on `staging`
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    llvmPackages.lld
  ];

  buildInputs = [
    graphene
    orc
    libtheora
    libintl
    libopus
    isocodes
    libpng
    libjpeg
    tremor
    pango
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    libdrm
    libGL
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    apple-sdk_gstreamer
  ]
  ++ lib.optionals enableAlsa [
    alsa-lib
  ]
  ++ lib.optionals enableX11 [
    libxext
    libxi
    libxv
  ]
  ++ lib.optionals enableWayland [
    wayland
    wayland-protocols
  ]
  ++ lib.optional enableCdparanoia cdparanoia;

  propagatedBuildInputs = [
    gstreamer
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    libdrm
  ];

  mesonFlags = [
    "-Dglib_debug=disabled" # cast checks should be disabled on stable releases
    "-Dexamples=disabled" # requires many dependencies and probably not useful for our users
    # See https://github.com/GStreamer/gst-plugins-base/blob/d64a4b7a69c3462851ff4dcfa97cc6f94cd64aef/meson_options.txt#L15 for a list of choices
    "-Dgl_winsys=${
      lib.concatStringsSep "," (
        lib.optional enableX11 "x11"
        ++ lib.optional enableWayland "wayland"
        ++ lib.optional enableCocoa "cocoa"
      )
    }"
    (lib.mesonEnable "introspection" withIntrospection)
    (lib.mesonEnable "doc" enableDocumentation)
    (lib.mesonEnable "libvisual" false)
  ]
  ++ lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
    "-Dtests=disabled"
  ]
  ++ lib.optionals (!enableX11) [
    "-Dx11=disabled"
    "-Dxi=disabled"
    "-Dxshm=disabled"
    "-Dxvideo=disabled"
  ]
  # TODO How to disable Wayland?
  ++ lib.optional (!enableGl) "-Dgl=disabled"
  ++ lib.optional (!enableAlsa) "-Dalsa=disabled"
  ++ lib.optional (!enableCdparanoia) "-Dcdparanoia=disabled"
  ++ lib.optional stdenv.hostPlatform.isDarwin "-Ddrm=disabled";

  # Fix for ld64 hardening issue
  #
  # TODO: Clean up on `staging`
  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    CC_LD = "lld";
    OBJC_LD = "lld";
  };

  doCheck = false; # fails, wants DRI access for OpenGL

  preFixup = ''
    moveToOutput "lib/gstreamer-1.0/pkgconfig" "$dev"
  '';

  __structuredAttrs = true;

  depsBuildBuild = [
    pkg-config
  ];

  # This package has some `_("string literal")` string formats
  # that trip up clang with format security enabled.
  hardeningDisable = [ "format" ];
  separateDebugInfo = true;

  passthru = {
    # Downstream `gst-*` packages depending on `gst-plugins-base`
    # have meson build options like 'gl' etc. that depend
    # on these features being built in `-base`.
    # If they are not built here, then the downstream builds
    # will fail, as they, too, use `-Dauto_features=enabled`
    # which would enable these options unconditionally.
    # That means we must communicate to these downstream packages
    # if the `-base` enabled these options or not, so that
    # the can enable/disable those features accordingly.
    # The naming `*Enabled` vs `enable*` is intentional to
    # distinguish inputs from outputs (what is to be built
    # vs what was built) and to make them easier to search for.
    glEnabled = enableGl;
    updateScript = directoryListingUpdater { odd-unstable = true; };
    waylandEnabled = enableWayland;
  };

  passthru.tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

  meta = {
    description = "Base GStreamer plug-ins and helper libraries";
    homepage = "https://gstreamer.freedesktop.org";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ tmarkus ];
    platforms = lib.platforms.unix;

    pkgConfigModules = [
      "gstreamer-audio-1.0"
      "gstreamer-base-1.0"
      "gstreamer-net-1.0"
      "gstreamer-video-1.0"
    ];
  };
})
