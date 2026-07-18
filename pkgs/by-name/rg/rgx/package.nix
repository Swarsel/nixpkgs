{
  lib,
  fetchFromGitHub,
  nix-update-script,
  pcre2,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rgx";
  version = "0.14.2";

  src = fetchFromGitHub {
    owner = "brevity1swos";
    repo = "rgx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lg5jKadvaoOWTrwQ6Hm44wUmdSHNivpYLHhCNS7J2Gs=";
  };

  buildInputs = [ pcre2 ];
  cargoHash = "sha256-bdqf24P4Q5jdNjr9CEN+QQpwvtdM2dTb1BHPxAQKrio=";
  __structuredAttrs = true;
  buildFeatures = [ "pcre2-engine" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "^v(\\d+\\.\\d+\\.\\d+)$"
    ];
  };

  meta = {
    description = "Terminal regex tester with real-time matching and multi-engine support";
    homepage = "https://github.com/brevity1swos/rgx";
    changelog = "https://github.com/brevity1swos/rgx/releases/tag/${finalAttrs.src.tag}";

    license = with lib.licenses; [
      asl20 # or
      mit
    ];

    maintainers = with lib.maintainers; [
      Cameo007
      kybe236
    ];

    mainProgram = "rgx";
  };
})
