{
  lib,
  stdenv,
  alsa-lib,
  atk,
  autoconf,
  automake,
  buildPackages,
  cairo,
  capnproto,
  clang,
  cmake,
  curl,
  dbus,
  dbus-glib,
  fontconfig,
  foundationdb,
  freetype,
  fuse3,
  gdk-pixbuf,
  glib,
  gmp,
  gobject-introspection,
  graphene,
  gtk3,
  gtk4,
  libevdev,
  libgit2,
  libpq,
  libsodium,
  libsoup_3,
  libssh2,
  libtool,
  linux-pam,
  llvmPackages,
  nettle,
  openssl,
  pango,
  pkg-config,
  protobuf,
  python3,
  rdkafka,
  seatd, # =libseat
  sqlite,
  udev,
  webkitgtk_4_1,
  zlib,
  zstd,
  ...
}:

{
  alsa-sys = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ alsa-lib ];
  };

  atk-sys = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ atk ];
  };

  # Force using the cmake backend. At least on Darwin, the build else gets confused and fails.
  aws-lc-sys = prev: {
    nativeBuildInputs = [ cmake ];
    env.AWS_LC_SYS_CMAKE_BUILDER = 1;
  };

  cairo-rs = attrs: {
    buildInputs = [ cairo ];
  };

  cairo-sys-rs = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ cairo ];
    extraLinkFlags = [ "-L${zlib.out}/lib" ];
  };

  capnp-rpc = attrs: {
    nativeBuildInputs = [ capnproto ];
  };

  cargo = attrs: {
    buildInputs = [
      openssl
      zlib
      curl
    ];
  };

  curl-sys = attrs: {
    nativeBuildInputs = [ pkg-config ];

    buildInputs = [
      zlib
      curl
    ];

    propagatedBuildInputs = [
      curl
      zlib
    ];

    extraLinkFlags = [ "-L${zlib.out}/lib" ];
  };

  dbus = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ dbus ];
  };

  evdev-sys = attrs: {
    nativeBuildInputs = [
      pkg-config
    ]
    ++ lib.optionals (stdenv.buildPlatform.config != stdenv.hostPlatform.config) [
      python3
      autoconf
      automake
      libtool
    ];

    buildInputs = [ libevdev ];

    # This prevents libevdev's build.rs from trying to `git fetch` when HOST!=TARGET
    prePatch = ''
      touch libevdev/.git
    '';
  };

  expat-sys = attrs: {
    nativeBuildInputs = [ cmake ];
  };

  foundationdb = attrs: {
    buildInputs = [ foundationdb ];
  };

  foundationdb-sys = attrs: {
    buildInputs = [ foundationdb ];
    # needed for 0.4+ release, when the FFI bindings are auto-generated
    #
    # patchPhase = ''
    #   substituteInPlace ./foundationdb-sys/build.rs \
    #     --replace /usr/local/include ${foundationdb.dev}/include
    # '';
  };

  freetype-sys = attrs: {
    nativeBuildInputs = [ cmake ];
    buildInputs = [ freetype ];
  };

  fuser = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ fuse3 ];
  };

  gdk-pixbuf = attrs: {
    buildInputs = [
      dbus-glib
      gdk-pixbuf
    ];
  };

  gdk-pixbuf-sys = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ gdk-pixbuf ];
  };

  gdk-sys = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ gtk3 ]; # libgdk-3
  };

  gdk4-sys = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ gtk4 ];
  };

  gdkx11-sys = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ gtk3 ];
  };

  gio-sys = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ dbus-glib ];
  };

  glib-sys = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ glib ];
    extraLinkFlags = [ "-L${zlib.out}/lib" ];
  };

  gobject-sys = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ dbus-glib ];
  };

  graphene-sys = attrs: {
    nativeBuildInputs = [
      pkg-config
      gobject-introspection
    ];

    buildInputs = [ graphene ];
  };

  gsk4-sys = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ gtk4 ];
  };

  gtk-sys = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ gtk3 ];
  };

  gtk4-sys = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ gtk4 ];
  };

  javascriptcore-rs-sys = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ webkitgtk_4_1 ];
  };

  libdbus-sys = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ dbus ];
  };

  libgit2-sys = attrs: {
    nativeBuildInputs = [ pkg-config ];

    buildInputs = [
      openssl
      zlib
      libgit2
    ];

    LIBGIT2_SYS_USE_PKG_CONFIG = true;
  };

  libseat-sys = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ seatd ];
  };

  libsqlite3-sys = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ sqlite ];
  };

  libssh2-sys = attrs: {
    nativeBuildInputs = [ pkg-config ];

    buildInputs = [
      openssl
      zlib
      libssh2
    ];
  };

  libudev-sys = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ udev ];
  };

  libz-sys = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ zlib ];
    extraLinkFlags = [ "-L${zlib.out}/lib" ];
  };

  nettle-sys = attrs: {
    nativeBuildInputs = [ pkg-config ];

    buildInputs = [
      nettle
      clang
    ];

    LIBCLANG_PATH = "${lib.getLib llvmPackages.libclang}/lib";
  };

  openssl = attrs: {
    buildInputs = [ openssl ];
  };

  openssl-sys = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ openssl ];
  };

  opentelemetry-proto = attrs: {
    nativeBuildInputs = [ protobuf ];
  };

  pam-sys = attr: {
    buildInputs = [ linux-pam ];
  };

  pango-sys = attr: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ pango ];
  };

  pangocairo-sys = attr: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ pango ];
  };

  pq-sys = attr: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ libpq ];
  };

  # Assumes it can run Command::new(env::var("CARGO")).arg("locate-project")
  # https://github.com/bkchr/proc-macro-crate/blame/master/src/lib.rs#L242
  proc-macro-crate =
    attrs:
    lib.optionalAttrs (lib.versionAtLeast attrs.version "2.0") {
      postPatch = (attrs.postPatch or "") + ''
        substituteInPlace \
          src/lib.rs \
          --replace-fail \
          'env::var("CARGO")' \
          'Ok::<_, core::convert::Infallible>("${lib.getBin buildPackages.cargo}/bin/cargo")'
      '';
    };

  prost-build = attr: {
    nativeBuildInputs = [ protobuf ];
  };

  prost-wkt-types = attr: {
    nativeBuildInputs = [ protobuf ];
  };

  rdkafka-sys = attr: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ rdkafka ];
  };

  rink = attrs: {
    buildInputs = [ gmp ];

    crateBin = [
      {
        name = "rink";
        path = "src/bin/rink.rs";
      }
    ];
  };

  sequoia-guide = attrs: {
    buildInputs = [ gmp ];
  };

  sequoia-ipc = attrs: {
    buildInputs = [ gmp ];
  };

  sequoia-openpgp = attrs: {
    buildInputs = [ gmp ];
  };

  sequoia-openpgp-ffi = attrs: {
    buildInputs = [ gmp ];
  };

  sequoia-sq = attrs: {
    buildInputs = [
      sqlite
      gmp
    ];
  };

  sequoia-store = attrs: {
    nativeBuildInputs = [ capnproto ];

    buildInputs = [
      sqlite
      gmp
    ];
  };

  sequoia-tool = attrs: {
    nativeBuildInputs = [ capnproto ];

    buildInputs = [
      sqlite
      gmp
    ];
  };

  servo-fontconfig-sys = attrs: {
    nativeBuildInputs = [ pkg-config ];

    buildInputs = [
      freetype
      fontconfig
    ];
  };

  soup3-sys = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ libsoup_3 ];
    extraLinkFlags = [ "-L${zlib.out}/lib" ];
  };

  thrussh-libsodium = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ libsodium ];
  };

  tonic-reflection = attrs: {
    nativeBuildInputs = [ protobuf ];
  };

  webkit2gtk-sys = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ webkitgtk_4_1 ];
    extraLinkFlags = [ "-L${zlib.out}/lib" ];
  };

  xcb = attrs: {
    buildInputs = [ python3 ];
  };

  zstd-sys = attrs: {
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ zstd ];
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };
}
