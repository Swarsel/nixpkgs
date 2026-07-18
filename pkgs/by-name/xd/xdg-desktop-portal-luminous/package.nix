{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  cargo,
  glib,
  libGL,
  libgbm,
  libxkbcommon,
  meson,
  ninja,
  nix-update-script,
  pango,
  pipewire,
  pkg-config,
  rustPlatform,
  rustc,
  wayland,
  xdg-desktop-portal,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xdg-desktop-portal-luminous";
  version = "0.1.14";

  src = fetchFromGitHub {
    owner = "waycrate";
    repo = "xdg-desktop-portal-luminous";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GiB0flnJgRgW7nYr+XdEyZ8rkTrZ94O8iedPUSLU9Lo=";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    rustc
    cargo
    rustPlatform.cargoSetupHook
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    xdg-desktop-portal
    cairo
    pango
    glib
    pipewire
    libgbm
    libGL
    libxkbcommon
  ];

  postInstall = ''
    patchelf \
      --add-needed libwayland-client.so.0 \
      --add-rpath ${lib.makeLibraryPath [ wayland ]} \
      $out/libexec/xdg-desktop-portal-luminous
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-bGBq7D+Tugjddu2jp9Cl5s/qpEfqmrnFsodeAVK9a9s=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "xdg-desktop-portal backend for wlroots based compositors, providing screenshot and screencast";
    homepage = "https://github.com/waycrate/xdg-desktop-portal-luminous";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ Rishik-Y ];
    platforms = lib.platforms.linux;
  };
})
