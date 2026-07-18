{
  lib,
  fetchFromGitHub,
  apple-sdk,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rift-wm";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "acsandmann";
    repo = "rift";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oOVNq4/hdiRcCbc9kaMxynnq2gXVezviQRTvjrdkfPs=";
  };

  nativeBuildInputs = [
    apple-sdk
  ];

  cargoHash = "sha256-eb3Z5NIUusJApQWa6sDMRP//Y0BOToQsEIhQqqR728o=";
  __structuredAttrs = true;

  meta = {
    description = "Tiling window manager for macos";
    homepage = "https://github.com/acsandmann/rift";
    changelog = "https://github.com/acsandmann/rift/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ eveeifyeve ];
    platforms = lib.platforms.darwin;
    mainProgram = "rift";
  };
})
