{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "impala";
  version = "0.7.4";

  src = fetchFromGitHub {
    owner = "pythops";
    repo = "impala";
    rev = "v${finalAttrs.version}";
    hash = "sha256-GQg/1asi+6hTyOK4cWkAvFJhnWTewFUOn7fAlL+tkUo=";
  };

  # fix for compilation of musl builds on aarch64
  # see https://github.com/NixOS/nixpkgs/issues/145726
  postPatch = ''
    rm .cargo/config.toml
  '';

  cargoHash = "sha256-shIv6fjWAZhIeSzxcHfzxfg2brTP1G3MBAixdi0GoK4=";

  meta = {
    description = "TUI for managing wifi";
    homepage = "https://github.com/pythops/impala";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      nydragon
      saadndm
    ];

    platforms = lib.platforms.linux;
    mainProgram = "impala";
  };
})
