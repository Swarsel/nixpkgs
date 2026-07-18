{
  lib,
  stdenv,
  fetchFromGitLab,
  apple-sdk_gstreamer,
  cairo,
  cargo,
  cargo-c,
  cmake,
  csound,
  dav1d,
  gst-plugins-bad,
  gst-plugins-base,
  gst-plugins-good,
  gstreamer,
  gtk4,
  hotdoc,
  libsodium,
  libwebp,
  lld,
  meson,
  nasm,
  ninja,
  nix-update-script,
  openssl,
  pango,
  pkg-config,
  python3,
  rustPlatform,
  rustc,
  # Checks meson.is_cross_build(), so even canExecute isn't enough.
  enableDocumentation ? stdenv.hostPlatform == stdenv.buildPlatform && plugins == null,
  # specifies a limited subset of plugins to build (the default `null` means all plugins supported on the stdenv platform)
  plugins ? null,
  withGtkPlugins ? true,
}:

let
  # populated from meson_options.txt (manually for now, but that might change in the future)
  validPlugins = {
    # audio
    audiofx = [ ];
    # net
    aws = [ openssl ];
    # video
    cdg = [ ];
    claxon = [ ];
    closedcaption = [ pango ];
    csound = [ csound ];
    dav1d = [ dav1d ];
    # utils
    fallbackswitch = [ gtk4 ];
    ffv1 = [ ];
    # generic
    file = [ ];
    # mux
    flavors = [ ];
    fmp4 = [ ];
    gif = [ ];
    gtk4 = [ gtk4 ];
    hlssink3 = [ ];
    hsv = [ ];
    json = [ ];
    lewton = [ ];
    livesync = [ gtk4 ];
    mp4 = [ ];
    ndi = [ ];
    onvif = [ pango ];
    png = [ ];
    raptorq = [ ];
    rav1e = [ ];
    regex = [ ];
    reqwest = [ openssl ];
    rtp = [ ];
    sodium = [ libsodium ];
    spotify = [ ];
    # text
    textahead = [ ];
    textwrap = [ ];
    threadshare = [ ];
    togglerecord = [ gtk4 ];
    tracers = [ ];
    uriplaylistbin = [ ];
    videofx = [ cairo ];
    webp = [ libwebp ];

    webrtc = [
      gst-plugins-bad
      openssl
    ];

    webrtchttp = [
      gst-plugins-bad
      openssl
    ];
  };

  selectedPlugins =
    if plugins != null then
      lib.unique (lib.sort lib.lessThan plugins)
    else
      lib.subtractLists (
        [
          "csound" # tests have weird failure on x86, does not currently work on arm or darwin
          "livesync" # tests have suspicious intermittent failure, see https://gitlab.freedesktop.org/gstreamer/gst-plugins-rs/-/issues/357
        ]
        ++ lib.optionals stdenv.hostPlatform.isAarch64 [
          "raptorq" # pointer alignment failure in tests on aarch64
        ]
        ++ lib.optionals stdenv.hostPlatform.isDarwin [
          "reqwest" # tests hang on darwin
          "threadshare" # tests cannot bind to localhost on darwin
          "uriplaylistbin" # thread reqwest-internal-sync-runtime attempred to create a NULL object (in test_cache)
          "webp" # not supported on darwin (upstream crate issue)
        ]
        ++ lib.optionals (!gst-plugins-base.glEnabled || !withGtkPlugins) [
          # these require gstreamer-gl
          "gtk4"
          "livesync"
          "fallbackswitch"
          "togglerecord"
        ]
      ) (lib.attrNames validPlugins);

  invalidPlugins = lib.subtractLists (lib.attrNames validPlugins) selectedPlugins;
in
assert lib.assertMsg (invalidPlugins == [ ])
  "Invalid gst-plugins-rs plugin${
    lib.optionalString (lib.length invalidPlugins > 1) "s"
  }: ${lib.concatStringsSep ", " invalidPlugins}";

stdenv.mkDerivation (finalAttrs: {
  pname = "gst-plugins-rs";
  version = "0.14.4";

  src = fetchFromGitLab {
    owner = "gstreamer";
    repo = "gst-plugins-rs";
    rev = finalAttrs.version;
    hash = "sha256-MZyYHMq6gFJkVxlrmeXUjOmRYsQBHj0848cnF+7mtbU=";
    domain = "gitlab.freedesktop.org";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    meson
    ninja
    python3
    python3.pkgs.tomli
    pkg-config
    rustc
    cargo
    cargo-c
    nasm
  ]
  # aws-lc-rs has no pregenerated bindings for exotic platforms
  # https://aws.github.io/aws-lc-rs/platform_support.html
  ++ lib.optionals (!(stdenv.hostPlatform.isx86 || stdenv.hostPlatform.isAarch64)) [
    cmake
    rustPlatform.bindgenHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    lld
  ]
  ++ lib.optionals enableDocumentation [
    hotdoc
  ];

  buildInputs = [
    gstreamer
    gst-plugins-base
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    apple-sdk_gstreamer
  ]
  ++ lib.concatMap (plugin: lib.getAttr plugin validPlugins) selectedPlugins;

  mesonFlags = (map (plugin: lib.mesonEnable plugin true) selectedPlugins) ++ [
    (lib.mesonOption "sodium-source" "system")
    (lib.mesonEnable "tests" finalAttrs.finalPackage.doCheck)
    (lib.mesonEnable "doc" enableDocumentation)
  ];

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin { NIX_CFLAGS_LINK = "-fuse-ld=lld"; };

  # csound lib dir must be manually specified for it to build
  preConfigure = ''
    export CARGO_BUILD_JOBS=$NIX_BUILD_CORES

    patchShebangs dependencies.py
  ''
  + lib.optionalString (lib.elem "csound" selectedPlugins) ''
    export CSOUND_LIB_DIR=${lib.getLib csound}/lib
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  checkInputs = [
    gst-plugins-good
    gst-plugins-bad
  ];

  preCheck = ''
    # Fontconfig error: No writable cache directories
    export XDG_CACHE_HOME=$(mktemp -d)
  '';

  postInstall = ''
    install -Dm444 -t ''${!outputDev}/lib/pkgconfig gst*.pc
  '';

  doInstallCheck =
    (lib.elem "webp" selectedPlugins) && !stdenv.hostPlatform.isStatic && stdenv.hostPlatform.isElf;

  installCheckPhase = ''
    runHook preInstallCheck
    readelf -a $out/lib/gstreamer-1.0/libgstrswebp.so | grep -F 'Shared library: [libwebpdemux.so'
    runHook postInstallCheck
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-T+fdu+Oe07Uf1YoRGYl2DMb1QgdSZVLwcOqH4bBNGXU=";
    name = "gst-plugins-rs-${finalAttrs.version}";
  };

  # turn off all auto plugins since we use a list of plugins we generate
  mesonAutoFeatures = "disabled";
  mesonCheckFlags = [ "--verbose" ];

  passthru = {
    updateScript = nix-update-script {
      # use numbered releases rather than gstreamer-* releases
      # this matches upstream's recommendation: https://gitlab.freedesktop.org/gstreamer/gst-plugins-rs/-/issues/470#note_2202772
      extraArgs = [
        "--version-regex"
        "([0-9.]+)"
      ];
    };
  };

  meta = {
    description = "GStreamer plugins written in Rust";
    homepage = "https://gitlab.freedesktop.org/gstreamer/gst-plugins-rs";

    license = with lib.licenses; [
      mpl20
      asl20
      mit
      lgpl21Plus
    ];

    maintainers = with lib.maintainers; [ tmarkus ];
    platforms = lib.platforms.unix;
    mainProgram = "gst-webrtc-signalling-server";
  };
})
