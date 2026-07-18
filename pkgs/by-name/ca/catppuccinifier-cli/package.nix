{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "catppuccinifier-cli";
  version = "9.1.0";

  src = fetchFromGitHub {
    owner = "lighttigerXIV";
    repo = "catppuccinifier";
    tag = finalAttrs.version;
    hash = "sha256-e8sLYp+0YhC/vAn4vag9UUaw3VYDRERGnLD1RuW1TXE=";
  };

  cargoHash = "sha256-mIzRK4rqD8ON8LqkG3QhOseZLM5+Rr1Rhj1uuu+KRMI=";
  sourceRoot = "${finalAttrs.src.name}/src/catppuccinifier-cli";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Apply catppuccin flavors to your wallpapers";
    homepage = "https://github.com/lighttigerXIV/catppuccinifier";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      aleksana
      isabelroses
    ];

    platforms = with lib.platforms; linux ++ windows;
    mainProgram = "catppuccinifier-cli";
  };
})
