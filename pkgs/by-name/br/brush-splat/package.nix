{
  lib,
  stdenv,
  fetchFromGitHub,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  nix-update-script,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  vulkan-loader,
  wayland,
  zstd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "brush-splat";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "ArthurBrussee";
    repo = "brush";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xVYZrQUgHxaefAMmSXG/rrVlCr0H5lRmyyXtRmOtbTU=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    zstd
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libx11
    libxcursor
    libxi
    libxkbcommon
    libxrandr
    vulkan-loader
    wayland
  ];

  cargoHash = "sha256-KBgE0fiaUEsGuAYGhBjqMX7ftj5JnGggH86brxq6280=";

  env = {
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf --add-rpath "${
      lib.makeLibraryPath [
        vulkan-loader
        wayland
        libxkbcommon
      ]
    }" $out/bin/brush_app
  '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "3D Reconstruction for all";
    homepage = "https://github.com/ArthurBrussee/brush";
    changelog = "https://github.com/ArthurBrussee/brush/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ matthewcroughan ];
    platforms = lib.platforms.linux;
    mainProgram = "brush_app";
  };
})
