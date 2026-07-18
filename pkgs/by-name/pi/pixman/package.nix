{
  lib,
  stdenv,
  fetchurl,
  __flattenIncludeHackHook,
  # for passthru.tests
  cairo,
  gitUpdater,
  glib, # just passthru
  libpng,
  meson,
  ninja,
  openmpCheckPhaseHook,
  pkg-config,
  qemu,
  scribus,
  testers,
  tigervnc,
  wlroots_0_19,
  xwayland,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pixman";
  version = "0.46.4";

  src = fetchurl {
    hash = "sha256-0JxE68O9W+5wIcefki/o+y+1f3Mg9V6X/5kU0jRqWRw=";

    urls = [
      "mirror://xorg/individual/lib/pixman-${finalAttrs.version}.tar.gz"
      "https://cairographics.org/releases/pixman-${finalAttrs.version}.tar.gz"
    ];
  };

  # Raise test timeout, 120s can be slightly exceeded on slower hardware
  postPatch = ''
    substituteInPlace test/meson.build \
      --replace-fail 'timeout : 120' 'timeout : 240'
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    openmpCheckPhaseHook
    __flattenIncludeHackHook
  ];

  buildInputs = [ libpng ];

  # fix armv7 build
  mesonFlags = lib.optionals stdenv.hostPlatform.isAarch32 [
    "-Darm-simd=disabled"
    "-Dneon=disabled"
  ];

  doCheck = !stdenv.hostPlatform.isDarwin;
  enableParallelBuilding = true;
  # Default "enabled" value attempts to enable CPU features on all
  # architectures and requires used to disable them:
  #   https://gitlab.freedesktop.org/pixman/pixman/-/issues/88
  mesonAutoFeatures = "auto";
  separateDebugInfo = !stdenv.hostPlatform.isStatic;

  passthru = {
    tests = {
      inherit
        cairo
        qemu
        scribus
        tigervnc
        wlroots_0_19
        xwayland
        ;

      pkg-config = testers.hasPkgConfigModules {
        package = finalAttrs.finalPackage;
      };
    };

    updateScript = gitUpdater {
      rev-prefix = "pixman-";
      url = "https://gitlab.freedesktop.org/pixman/pixman.git";
    };
  };

  meta = {
    description = "Low-level library for pixel manipulation";
    homepage = "https://pixman.org";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    pkgConfigModules = [ "pixman-1" ];
  };
})
