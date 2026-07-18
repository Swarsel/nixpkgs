{
  lib,
  stdenv,
  cargo,
  cmake,
  corrosion,
  fetchFromCodeberg,
  nix-update-script,
  rustPlatform,
  rustc,
  sqlite,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libchewing";
  version = "0.13.0";

  src = fetchFromCodeberg {
    owner = "chewing";
    repo = "libchewing";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1/aamkc66pjAf/jl4pD2rJ9ipFW0bAWjvKg6KtINWuQ=";
    fetchSubmodules = true;
  };

  # ld: unknown option: -version-script
  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "if(CMAKE_C_COMPILER_ID MATCHES GNU|^Clang)" "if((CMAKE_C_COMPILER_ID MATCHES GNU|^Clang) AND NOT APPLE)"
  '';

  nativeBuildInputs = [
    cmake
    rustPlatform.cargoSetupHook
    cargo
    rustc
  ];

  buildInputs = [
    sqlite
    corrosion
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-1b8GbZ75jBVmvXquOjG2CEcLXg4AthAwQzdO68CjjPs=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Intelligent Chinese phonetic input method";
    homepage = "https://chewing.im/";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ ShamrockLee ];
    platforms = lib.platforms.all;
    # compile time tools init_database, dump_database are built for host
    broken = !stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  };
})
