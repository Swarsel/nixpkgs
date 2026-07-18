{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  libGL,
  libxkbcommon,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "oklch-color-picker";
  version = "2.3.4";

  src = fetchFromGitHub {
    owner = "eero-lehtinen";
    repo = "oklch-color-picker";
    tag = finalAttrs.version;
    hash = "sha256-AdLpP01VeeAAOBEeX/dxLPdAqTfgH9X+NDCmFgqA3hs=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  cargoHash = "sha256-FB8zvWhO+ZbzWjkQCnf3ghgM+IL4px7QNO4dLPcczec=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  runtimeDependencies = [
    libGL
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wayland
    libxkbcommon
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Color picker for Oklch";

    longDescription = ''
      A standalone color picker application using the Oklch
      colorspace (based on Oklab)
    '';

    homepage = "https://github.com/eero-lehtinen/oklch-color-picker";
    changelog = "https://github.com/eero-lehtinen/oklch-color-picker/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ videl ];
  };
})
