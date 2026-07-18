{
  lib,
  stdenv,
  fetchFromGitHub,
  fontconfig,
  icu,
  libGL,
  libdrm,
  libgbm,
  libinput,
  libx11,
  libxcursor,
  libxkbcommon,
  meson,
  ninja,
  nix-update-script,
  pixman,
  pkg-config,
  seatd,
  srm-cuarzo,
  udev,
  wayland,
  xorgproto,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "louvre";
  version = "2.18.1-1";

  src = fetchFromGitHub {
    owner = "CuarzoSoftware";
    repo = "Louvre";
    rev = "v${finalAttrs.version}";
    hash = "sha256-wkOY3ARq7x3roRflRN8rMSbrI5B4amI+0CVJmfLYx2w=";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    substituteInPlace examples/meson.build \
      --replace-fail "/usr/local/share/wayland-sessions" "${placeholder "out"}/share/wayland-sessions"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    fontconfig
    icu
    libdrm
    libGL
    libinput
    libx11
    libxcursor
    libxkbcommon
    libgbm
    pixman
    seatd
    srm-cuarzo
    udev
    wayland
    xorgproto
  ];

  sourceRoot = "${finalAttrs.src.name}/src";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "C++ library for building Wayland compositors";
    homepage = "https://github.com/CuarzoSoftware/Louvre";
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "louvre-views";
  };
})
