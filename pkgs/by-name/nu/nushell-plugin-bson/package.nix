{
  lib,
  fetchFromGitHub,
  llvmPackages,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nu_plugin_bson";
  version = "26.1130.0";

  src = fetchFromGitHub {
    owner = "Kissaki";
    repo = "nu_plugin_bson";
    tag = "v${finalAttrs.version}";
    hash = "sha256-H+pgAckWFW/jPnIL6i90BBothX5zT3/hbcDhmdvdZmY=";
  };

  nativeBuildInputs = [
    llvmPackages.libclang
  ];

  cargoHash = "sha256-aGUlItPfrr3Uz/t1XEXBtGM285up3A5Wva1QMKwBrg0=";
  env.LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
  passthru.update-script = nix-update-script { };

  meta = {
    description = " Nushell plugin for BSON (Binary JSON) format `from bson` and `to bson`";
    homepage = "https://github.com/Kissaki/nu_plugin_bson";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ philocalyst ];
    platforms = lib.platforms.unix ++ lib.platforms.windows;
    mainProgram = "nu_plugin_bson";
  };
})
