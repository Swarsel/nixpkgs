{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "nom";
  version = "3.3.2";

  src = fetchFromGitHub {
    owner = "guyfedwards";
    repo = "nom";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZsauLHdGkD6cJ9SYwoTyOLu2CDLp8tBGqXn4jDElAMA=";
  };

  vendorHash = "sha256-otrK4mTqgRr9Ntf2D1f0/deQcObejRWN7BaScV4q+FY=";
  # only run xdg-specific test on linux
  checkFlags = lib.optional stdenv.hostPlatform.isDarwin "-skip=^TestNewDefaultWithXDGConfigHome$";

  ldflags = [
    "-X 'main.version=${finalAttrs.version}'"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "RSS reader for the terminal";
    homepage = "https://github.com/guyfedwards/nom";
    changelog = "https://github.com/guyfedwards/nom/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      nadir-ishiguro
      matthiasbeyer
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "nom";
  };
})
