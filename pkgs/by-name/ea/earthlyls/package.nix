{
  lib,
  fetchFromGitHub,
  earthlyls,
  nix-update-script,
  rustPlatform,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "earthlyls";
  version = "0.5.5";

  src = fetchFromGitHub {
    owner = "glehmann";
    repo = "earthlyls";
    rev = finalAttrs.version;
    hash = "sha256-GnFzfCjT4kjb9WViKIFDkIU7zVpiI6HDuUeddgHGQuc=";
  };

  cargoHash = "sha256-sWbYN92Jfr/Pr3qoHWkew/ASIdq8DQg0WHpdyklGBLo=";

  passthru = {
    tests.version = testers.testVersion { package = earthlyls; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Earthly language server";
    homepage = "https://github.com/glehmann/earthlyls";
    changelog = "https://github.com/glehmann/earthlyls/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "earthlyls";
  };
})
