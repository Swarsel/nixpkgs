{
  lib,
  fetchFromGitHub,
  cmake,
  cpm-cmake,
  fontconfig,
  libGL,
  libgbm,
  libx11,
  libxfixes,
  libxkbcommon,
  nix-update-script,
  openxr-loader,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "stardust-xr-server";
  version = "0.44.1";

  src = fetchFromGitHub {
    owner = "stardustxr";
    repo = "server";
    tag = finalAttrs.version;
    hash = "sha256-sCatpWDdy7NFWOWUARjN3fZMDVviX2iV79G0HTxfYZU=";
  };

  postPatch = ''
    install -D ${cpm-cmake}/share/cpm/CPM.cmake $(echo $cargoDepsCopy/*/stereokit-sys-*/StereoKit)/build/cpm/CPM_0.32.2.cmake
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    fontconfig
    libGL
    libxkbcommon
    libgbm
    openxr-loader
    libx11
    libxfixes
  ];

  cargoHash = "sha256-jCtMCZG3ku30tabTnVdGfgcLl5DoqhkJpLKPPliJgDU=";
  env.CPM_SOURCE_CACHE = "./build";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Wayland compositor and display server for 3D applications";
    homepage = "https://stardustxr.org/";
    changelog = "https://github.com/StardustXR/server/releases";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      pandapip1
      technobaboo
    ];

    platforms = lib.platforms.linux;
    mainProgram = "stardust-xr-server";
  };
})
