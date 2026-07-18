{
  lib,
  stdenv,
  fetchFromGitHub,
  # build deps
  cargo-deny,
  cmake,
  dbus,
  # runtime deps
  fontconfig,
  freetype,
  git,
  gnumake,
  gst_all_1,
  harfbuzz,
  libGL,
  libunwind,
  libx11,
  libxcb,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  llvm,
  llvmPackages,
  m4,
  makeWrapper,
  nix-update-script,
  # tests
  nixosTests,
  perl,
  pkg-config,
  python311,
  rustPlatform,
  taplo,
  udev,
  uv,
  vulkan-loader,
  wayland,
  which,
  yasm,
  zlib,
}:

let
  # match .python-version
  customPython = python311.withPackages (
    ps: with ps; [
      markupsafe
      packaging
      pygments
    ]
  );
  runtimePaths = lib.makeLibraryPath (
    lib.optionals (stdenv.hostPlatform.isLinux) [
      libxcursor
      libxrandr
      libxi
      libxkbcommon
      vulkan-loader
      wayland
      libGL
    ]
  );
in

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "servo";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "servo";
    repo = "servo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DfUjByBtDcOShExuBBLSHmgP9CPMSdkovw9QeGRDYaA=";

    # Breaks reproducibility depending on whether the picked commit
    # has other ref-names or not, which may change over time, i.e. with
    # "ref-names: HEAD -> main" as long this commit is the branch HEAD
    # and "ref-names:" when it is not anymore.
    postFetch = ''
      rm $out/tests/wpt/tests/tools/third_party/attrs/.git_archival.txt
    '';
  };

  nativeBuildInputs = [
    cargo-deny
    cmake
    customPython
    dbus
    git
    gnumake
    llvm
    llvmPackages.libstdcxxClang
    m4
    makeWrapper
    perl
    pkg-config
    rustPlatform.bindgenHook
    taplo
    uv
    which
    yasm
  ];

  buildInputs = [
    fontconfig
    freetype
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    harfbuzz
    libunwind
    libGL
    zlib
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wayland
    libx11
    libxcb
    udev
    vulkan-loader
  ];

  cargoHash = "sha256-N0MUtL0HslJHEQUCB0iMbXGdD9hA6GRqcmdSjjhsu8E=";

  env.NIX_CFLAGS_COMPILE = toString (
    [
      # mozjs-sys fails with:
      #  cc1plus: error: '-Wformat-security' ignored without '-Wformat'
      "-Wno-error=format-security"
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      "-I${lib.getInclude stdenv.cc.libcxx}/include/c++/v1"
    ]
  );

  env.UV_PYTHON = customPython.interpreter;

  # set `HOME` to a temp dir for write access
  # Fix invalid option errors during linking (https://github.com/mozilla/nixpkgs-mozilla/commit/c72ff151a3e25f14182569679ed4cd22ef352328)
  preConfigure = ''
    export HOME=$TMPDIR
    unset AS
  '';

  # copy resources into `$out` to be used during runtime
  # link runtime libraries
  postFixup = ''
    mkdir -p $out/resources
    cp -r ./resources $out/

    wrapProgram $out/bin/servoshell \
      --prefix LD_LIBRARY_PATH : ${runtimePaths}
  '';

  # Builds with additional features for aarch64, see https://github.com/servo/servo/issues/36819
  buildFeatures = lib.optionals stdenv.hostPlatform.isAarch64 [
    "servo-allocator/use-system-allocator"
  ];

  passthru = {
    tests = { inherit (nixosTests) servo; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Embeddable, independent, memory-safe, modular, parallel web rendering engine";
    homepage = "https://servo.org";
    changelog = "https://github.com/servo/servo/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mpl20;

    maintainers = with lib.maintainers; [
      hexa
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "servoshell";
    # undefined libmozjs_sys symbols during linking
    broken = stdenv.hostPlatform.isDarwin;
    teams = with lib.teams; [ ngi ];
  };
})
