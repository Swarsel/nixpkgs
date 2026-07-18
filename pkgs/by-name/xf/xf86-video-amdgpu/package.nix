{
  lib,
  stdenv,
  fetchFromGitLab,
  libGL,
  libdrm,
  libgbm,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  udev,
  xorg-server,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xf86-video-amdgpu";
  version = "25.0.0";

  src = fetchFromGitLab {
    owner = "driver";
    repo = "xf86-video-amdgpu";
    tag = "xf86-video-amdgpu-${finalAttrs.version}";
    hash = "sha256-7dLoKxBbE98FjADTYjjwj6OafJdecAkOCMRcYUYuYV4=";
    domain = "gitlab.freedesktop.org";
    group = "xorg";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    libdrm
    libgbm
    libGL
    udev
    xorgproto
    xorg-server
  ];

  # fixes https://github.com/NixOS/nixpkgs/issues/483585 aka https://gitlab.freedesktop.org/xorg/driver/xf86-video-amdgpu/-/issues/8
  hardeningDisable = [ "bindnow" ];

  passthru = {
    updateScript = nix-update-script { extraArgs = [ "--version-regex=xf86-video-amdgpu-(.*)" ]; };
  };

  meta = {
    description = "Xorg driver for AMD Radeon GPUs using the amdgpu kernel driver";
    homepage = "https://gitlab.freedesktop.org/xorg/driver/xf86-video-amdgpu";

    license = with lib.licenses; [
      hpndSellVariant
      mit
      x11
    ];

    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
