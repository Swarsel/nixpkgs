{
  lib,
  stdenv,
  fetchFromGitLab,
  alsa-lib,
  autoPatchelfHook,
  # macOS-only
  desktopToDarwinBundle,
  libx11,
  libxcb,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  pkg-config,
  rustPlatform,
  # Both platforms
  shaderc,
  udev,
  # Linux-only
  vulkan-loader,
  wayland,
}:

let
  # Note: use this to get the release metadata
  # https://gitlab.com/api/v4/projects/10174980/repository/tags/v{version}
  version = "0.18.0";
  timestamp = "1769191511";
  rev = "1d12f35edd6cdbfc1fb921c167cdd7beeeffe248";
in
rustPlatform.buildRustPackage {
  inherit version;
  pname = "veloren";

  src = fetchFromGitLab {
    inherit rev;
    owner = "veloren";
    repo = "veloren";
    hash = "sha256-tngIwFq18kvOU2XwCQoeLWjiVDjrJgOf3XIYz2J2cWs=";
  };

  postPatch = ''
    # Fix hashbrown on rust ≥1.95
    # (https://github.com/rust-lang/hashbrown/pull/662)
    substituteInPlace "$cargoDepsCopy"/*/hashbrown-0.16.0/src/lib.rs \
      --replace-fail 'strict_provenance_lints' 'strict_provenance_lints,trivial_clone'
    substituteInPlace "$cargoDepsCopy"/*/hashbrown-0.16.0/src/raw/mod.rs \
      --replace-fail 'T: Copy,' 'T: core::clone::TrivialClone,'

    # Force vek to build in unstable mode
    tee "$cargoDepsCopy"/*/vek-*/build.rs > /dev/null <<'EOF'
    fn main() {
      println!("cargo:rustc-check-cfg=cfg(nightly)");
      println!("cargo:rustc-cfg=nightly");
    }
    EOF

    # Fix assets path
    substituteAllInPlace common/assets/src/lib.rs

    # Do not use mold, it produces broken binaries
    substituteInPlace .cargo/config.toml --replace-fail mold gold
  '';

  nativeBuildInputs = [
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    desktopToDarwinBundle
  ];

  buildInputs = [
    shaderc
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    udev
    libxcb
    libxkbcommon
    stdenv.cc.cc # libgcc_s.so.1
  ];

  cargoHash = "sha256-1qLE1UeP2i0xaOGLniZzdjIkBbme6rctGfcO9Kfoh5E=";

  env = {
    # Enable unstable features, see https://gitlab.com/veloren/veloren/-/issues/264
    RUSTC_BOOTSTRAP = true;
    # Use system shaderc
    SHADERC_LIB_DIR = "${shaderc.lib}/lib";
    # Set version info, required by veloren-common
    VELOREN_GIT_VERSION = "/${lib.substring 0 8 rev}/${timestamp}";
    # Save game data under user's home directory,
    # otherwise it defaults to $out/bin/../userdata
    VELOREN_USERDATA_STRATEGY = "system";
  };

  # Some tests require internet access
  doCheck = false;

  postInstall = ''
    # Icons
    install -Dm644 assets/voxygen/net.veloren.veloren.desktop -t "$out/share/applications"
    install -Dm644 assets/voxygen/net.veloren.veloren.png -t "$out/share/icons/hicolor/256x256/apps"
    install -Dm644 assets/voxygen/net.veloren.veloren.metainfo.xml -t "$out/share/metainfo"

    # Assets directory
    mkdir -p "$out/share/veloren"; cp -ar assets "$out/share/veloren/"
  '';

  appendRunpaths = lib.optionals stdenv.hostPlatform.isLinux [
    (lib.makeLibraryPath (
      [
        libx11
        libxi
        libxcursor
        libxrandr
        libxkbcommon
        vulkan-loader
      ]
      ++ lib.optionals (lib.meta.availableOn stdenv.hostPlatform wayland) [
        wayland
      ]
    ))
  ];

  buildFeatures = [ "default-publish" ];
  buildNoDefaultFeatures = true;

  cargoPatches = [
    ./fix-assets-path.patch
  ];

  meta = {
    description = "Open world, open source voxel RPG";
    homepage = "https://www.veloren.net";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      rnhmjoj
      philocalyst
      tomodachi94
    ];

    platforms = lib.platforms.all;
    mainProgram = "veloren-voxygen";
  };
}
