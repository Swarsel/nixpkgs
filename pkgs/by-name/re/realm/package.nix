{
  lib,
  fetchFromGitHub,
  cmake,
  nix-update-script,
  nixosTests,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "realm";
  version = "2.9.4";

  src = fetchFromGitHub {
    owner = "zhboner";
    repo = "realm";
    rev = "v${finalAttrs.version}";
    hash = "sha256-gnsFqWhJOMKUaSWfRmHBksw3uWFP0smRhEbPLriEmlk=";
  };

  nativeBuildInputs = [
    cmake
    rustPlatform.bindgenHook
  ];

  cargoHash = "sha256-b/cG6fGoAdhvmZXSQv/QkY3QKiMT7YcfEGohZSbk0q8=";
  env.RUSTC_BOOTSTRAP = 1;

  passthru = {
    tests = { inherit (nixosTests) realm; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Simple, high performance relay server written in rust";
    homepage = "https://github.com/zhboner/realm";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ocfox ];
    mainProgram = "realm";
  };
})
