{
  lib,
  stdenv,
  cmake,
  fetchCrate,
  fontconfig,
  libGL,
  libx11,
  libxcb,
  libxcursor,
  libxi,
  libxkbcommon,
  nix-update-script,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  wayland,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "slint-lsp";
  version = "1.17.0";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-6TwEB3t0vwDnvGmZU1LSIkYbA02NEyVI4wbEeqYbatM=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    fontconfig
  ];

  buildInputs = finalAttrs.rpathLibs ++ [ libxcb.dev ];
  cargoHash = "sha256-RTWfR/RmijSj5DlS+9tJ6uG534NmG5jy+p1hliEsdiE=";
  # Tests requires `i_slint_backend_testing` which is only a dev dependency
  doCheck = false;

  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf --set-rpath ${lib.makeLibraryPath finalAttrs.rpathLibs} $out/bin/slint-lsp
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  dontPatchELF = true;

  rpathLibs = [
    fontconfig
    libGL
    libxcb
    libx11
    libxcursor
    libxi
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libxkbcommon
    wayland
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Language Server Protocol (LSP) for Slint UI language";
    homepage = "https://slint-ui.com/";
    changelog = "https://github.com/slint-ui/slint/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = with lib.maintainers; [ xgroleau ];
    mainProgram = "slint-lsp";
    downloadPage = "https://github.com/slint-ui/slint/";
  };
})
