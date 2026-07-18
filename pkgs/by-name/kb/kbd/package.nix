{
  lib,
  stdenv,
  autoPatchelfHook,
  autoreconfHook,
  bash,
  bashNonInteractive,
  bison,
  bzip2,
  check,
  coreutils,
  fetchgit,
  flex,
  gitUpdater,
  kbdVlock,
  nixosTests,
  pam,
  perl,
  pkg-config,
  pkgsCross,
  xz,
  zlib,
  zstd,
  withVlock ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kbd" + lib.optionalString withVlock "-vlock";
  version = "2.9.0";

  src = fetchgit {
    url = "https://git.kernel.org/pub/scm/linux/kernel/git/legion/kbd.git";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uUECxFdm/UhoHKLHLFe6/ygCQ+4mrQOZExKl+ReaTNw=";
  };

  outputs = [
    "out"
    "dev"
    "scripts"
    "man"
  ];

  patches = [
    ./search-paths.patch
  ];

  postPatch = ''
    # Renaming keymaps with name clashes, because loadkeys just picks
    # the first keymap it sees. The clashing names lead to e.g.
    # "loadkeys no" defaulting to a norwegian dvorak map instead of
    # the much more common qwerty one.
    pushd data/keymaps/i386
    mv qwertz/cz{,-qwertz}.map
    mv olpc/es{,-olpc}.map
    mv olpc/pt{,-olpc}.map
    mv fgGIod/trf{,-fgGIod}.map
    mv colemak/{en-latin9,colemak}.map
    popd
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    flex
    perl
    bison
    autoPatchelfHook # for patching dlopen()
  ];

  buildInputs = [
    zlib
    bzip2
    xz
    zstd
    bash
  ]
  ++ lib.optionals withVlock [ pam ];

  configureFlags = [
    "--enable-optional-progs"
    "--enable-libkeymap"
    "--disable-nls"
    (lib.enableFeature withVlock "vlock")
  ]
  ++ lib.optionals (!lib.systems.equals stdenv.buildPlatform stdenv.hostPlatform) [
    "ac_cv_func_malloc_0_nonnull=yes"
    "ac_cv_func_realloc_0_nonnull=yes"
  ];

  preConfigure = ''
    # Perl and Bash only used during build time
    patchShebangs --build contrib/
  '';

  nativeCheckInputs = [
    check
  ];

  postInstall = ''
    substituteInPlace $out/bin/unicode_{start,stop} \
      --replace-fail /usr/bin/tty ${coreutils}/bin/tty

    moveToOutput bin/unicode_start $scripts
    moveToOutput bin/unicode_stop $scripts
  '';

  __structuredAttrs = true;
  enableParallelBuilding = true;

  outputChecks.out.disallowedRequisites = [
    bash
    bashNonInteractive
  ];

  passthru = {
    tests = {
      inherit (nixosTests) keymap kbd-setfont-decompress kbd-update-search-paths-patch;

      cross =
        let
          systemString = if stdenv.buildPlatform.isAarch64 then "gnu64" else "aarch64-multiplatform";
        in
        pkgsCross.${systemString}.kbd;
    };

    updateScript = gitUpdater {
      rev-prefix = "v";
      # No nicer place to find latest release.
      url = "https://github.com/legionus/kbd.git";
    };

    # For backwards compatibility. Remove after 26.05.
    vlock = kbdVlock;
  };

  meta = {
    description = "Linux keyboard tools and keyboard maps";
    homepage = "https://kbd-project.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ davidak ];
    platforms = lib.platforms.linux;
  };
})
