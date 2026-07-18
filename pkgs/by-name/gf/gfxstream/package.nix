{
  lib,
  stdenv,
  aemu,
  fetchFromGitiles,
  fetchpatch,
  libdrm,
  libglvnd,
  libx11,
  # TODO: Clean up on `staging`.
  llvmPackages,
  meson,
  ninja,
  pkg-config,
  python3,
  vulkan-headers,
  vulkan-loader,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gfxstream";
  version = "0.1.2";

  src = fetchFromGitiles {
    url = "https://android.googlesource.com/platform/hardware/google/gfxstream";
    rev = "v${finalAttrs.version}-gfxstream-release";
    hash = "sha256-AN6OpZQ2te4iVuh/kFHXzmLAWIMyuoj9FHTVicnbiPw=";
  };

  patches = [
    # Fix build with gcc15
    ./gfxstream-add-include-cstdint.patch
  ];

  # Ensure that meson can find an Objective-C compiler on Darwin.
  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace meson.build \
      --replace-fail "project('gfxstream_backend', 'cpp', 'c'" "project('gfxstream_backend', 'cpp', 'c', 'objc'"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
  ]
  # TODO: Clean up on `staging`.
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    llvmPackages.lld
  ];

  buildInputs = [
    aemu
    libglvnd
    vulkan-headers
    vulkan-loader
    libx11
  ]
  ++ lib.optionals (lib.meta.availableOn stdenv.hostPlatform libdrm) [ libdrm ];

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    # TODO: Clean up on `staging`.
    NIX_CFLAGS_LINK = "-fuse-ld=lld";

    NIX_LDFLAGS = toString [
      "-framework Cocoa"
      "-framework IOKit"
      "-framework IOSurface"
      "-framework OpenGL"
      "-framework QuartzCore"
      "-needed-lvulkan"
    ];
  };

  # dlopens libvulkan.
  preConfigure = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    mesonFlagsArray=(-Dcpp_link_args="-Wl,--push-state -Wl,--no-as-needed -lvulkan -Wl,--pop-state")
  '';

  meta = {
    description = "Graphics Streaming Kit";
    homepage = "https://android.googlesource.com/platform/hardware/google/gfxstream";
    license = lib.licenses.free; # https://android.googlesource.com/platform/hardware/google/gfxstream/+/refs/heads/main/LICENSE
    maintainers = with lib.maintainers; [ qyliss ];
    platforms = aemu.meta.platforms;
  };
})
