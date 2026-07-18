{
  lib,
  fetchFromGitHub,
  applyPatches,
  appstream,
  cargo,
  clangStdenv,
  desktop-file-utils,
  ffmpeg,
  glib,
  glycin-loaders,
  gtk4,
  libadwaita,
  libglycin,
  libseccomp,
  libshumate,
  meson,
  ninja,
  nix-update-script,
  onnxruntime,
  opencv,
  openssl,
  pkg-config,
  rustPlatform,
  rustc,
  wrapGAppsHook4,
}:
# Apparently `bindgenHook` + `libclang` is not enough.
# opencv-binding-generator *really* wants to execute `clang` itself...
clangStdenv.mkDerivation (finalAttrs: {
  pname = "fotema";
  version = "2.4.2";

  src = fetchFromGitHub {
    owner = "blissd";
    repo = "fotema";
    tag = "v${finalAttrs.version}";
    hash = "sha256-g1CxgK8gaX24TFnlGUons3ve8Ow9YaiMh1kMwlcP/F8=";
  };

  patches = [
    # Bump ffmpeg-next 8.0.0 -> 8.1.0 in Cargo.lock for ffmpeg 8.1 compatibility.
    ./cargo-lock-bump-ffmpeg-next.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    rustPlatform.bindgenHook
    cargo
    rustc
    appstream
    desktop-file-utils # `desktop-file-validate`
    glib # `glib-compile-schemas`
    gtk4 # `gtk-update-icon-cache`
    wrapGAppsHook4
    libglycin.patchVendorHook
  ];

  buildInputs = [
    libadwaita
    openssl
    ffmpeg
    onnxruntime
    libshumate
    opencv
    libseccomp
    libglycin.setupHook
    glycin-loaders
  ];

  env = {
    OPENSSL_NO_VENDOR = true;
    # Use system OnnxRuntime
    ORT_LIB_LOCATION = "${onnxruntime}/lib";
    ORT_STRATEGY = "system";
  };

  preFixup = ''
    gappsWrapperArgs+=(
      --set ORT_DYLIB_PATH "${onnxruntime}/lib/libonnxruntime.so"
    )
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version;

    src = applyPatches {
      inherit (finalAttrs) src patches;
    };

    hash = "sha256-AEZY1QODq4F+CTrJce14qA6XSZjv29wSwIqUjZPWJo4=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Photo gallery for Linux";
    homepage = "https://github.com/blissd/fotema";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = with lib.maintainers; [ pluiedev ];
    platforms = lib.platforms.linux;
    mainProgram = "fotema";
  };
})
