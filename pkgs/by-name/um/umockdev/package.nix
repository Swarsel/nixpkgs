{
  lib,
  stdenv,
  fetchurl,
  docbook-xsl-nons,
  glib,
  gobject-introspection,
  gtk-doc,
  libgudev,
  libpcap,
  meson,
  mesonEmulatorHook,
  ninja,
  pkg-config,
  python3,
  replaceVars,
  systemdMinimal,
  usbutils,
  vala,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "umockdev";
  version = "0.19.3";

  src = fetchurl {
    url = "https://github.com/martinpitt/umockdev/releases/download/${finalAttrs.version}/umockdev-${finalAttrs.version}.tar.xz";
    hash = "sha256-RuReq29la/wJJDjX4OXfTF9R0Y46gzYMK+aAsgehoLc=";
  };

  outputs = [
    "bin"
    "out"
    "dev"
    "devdoc"
  ];

  patches = [
    # Hardcode absolute paths to libraries so that consumers
    # do not need to set LD_LIBRARY_PATH themselves.
    ./hardcode-paths.patch

    # Replace references to udevadm with an absolute paths, so programs using
    # umockdev will just work without having to provide it in their test environment
    # $PATH.
    (replaceVars ./substitute-udevadm.patch {
      udevadm = "${systemdMinimal}/bin/udevadm";
    })
  ];

  postPatch = ''
    # Substitute the path to this derivation in the patch we apply.
    substituteInPlace src/umockdev-wrapper \
      --subst-var-by 'LIBDIR' "''${!outputLib}/lib"
  ''
  + lib.optionalString stdenv.hostPlatform.isMusl ''
    substituteInPlace src/libumockdev-preload.c \
      --replace-fail libc.so.6 libc.so
  '';

  strictDeps = true;

  nativeBuildInputs = [
    docbook-xsl-nons
    gobject-introspection
    gtk-doc
    meson
    ninja
    pkg-config
    vala
  ]
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  buildInputs = [
    glib
    systemdMinimal
    libpcap
  ];

  mesonFlags = [
    "-Dgtk_doc=true"
  ];

  # glibc valgrind can't measure musl binaries (and vice versa)
  doCheck = stdenv.hostPlatform.libc == stdenv.buildPlatform.libc;

  nativeCheckInputs = [
    python3
    usbutils
    which
  ];

  checkInputs = lib.optionals finalAttrs.passthru.withGudev [
    libgudev
  ];

  preCheck = ''
    # Our patch makes the path to the `LD_PRELOAD`ed library absolute.
    # When running tests, the library is not yet installed, though,
    # so we need to replace the absolute path with a local one during build.
    # We are using a symlink that will be overridden during installation.
    mkdir -p "$out/lib"
    ln -s "$PWD/libumockdev-preload.so.0" "$out/lib/libumockdev-preload.so.0"
  '';

  passthru = {
    tests = {
      withGudev = finalAttrs.finalPackage.overrideAttrs (attrs: {
        passthru = attrs.passthru // {
          withGudev = true;
        };
      });
    };

    # libgudev is needed for an optional test but it itself relies on umockdev for testing.
    withGudev = false;
  };

  meta = {
    description = "Mock hardware devices for creating unit tests";
    homepage = "https://github.com/martinpitt/umockdev";
    changelog = "https://github.com/martinpitt/umockdev/releases/tag/${finalAttrs.version}";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ flokli ];
    platforms = with lib.platforms; linux;
  };
})
