{
  lib,
  stdenv,
  fetchFromGitHub,
  assimp,
  glm,
  libgbm,
  libxcb,
  libxcb-wm,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  vulkan-headers,
  vulkan-loader,
  wayland,
  wayland-protocols,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vkmark";
  version = "2025.01";

  src = fetchFromGitHub {
    owner = "vkmark";
    repo = "vkmark";
    rev = finalAttrs.version;
    sha256 = "sha256-Rjpjqe7htwlhDdwELm74MvSzHzXLhRD/P8IES7nz/VY=";
  };

  postPatch = ''
    substituteInPlace src/meson.build \
      --replace-fail "vulkan_dep.get_pkgconfig_variable('prefix')" "'${vulkan-headers}'"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    vulkan-headers
    vulkan-loader
    libgbm
    glm
    assimp
    libxcb
    libxcb-wm
    wayland
    wayland-protocols
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Extensible Vulkan benchmarking suite";
    homepage = "https://github.com/vkmark/vkmark";
    license = with lib.licenses; [ lgpl21Plus ];
    maintainers = with lib.maintainers; [ muscaln ];
    platforms = lib.platforms.linux;
    mainProgram = "vkmark";
  };
})
