{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nix-update-script,
  udev,
}:

buildNpmPackage (finalAttrs: {
  pname = "particle-cli";
  version = "3.45.0";

  src = fetchFromGitHub {
    owner = "particle-iot";
    repo = "particle-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Hq2flUBStEouVEhYI25fNFK9ohvHfk792vlPa7b3DRA=";
  };

  buildInputs = [
    udev
  ];

  npmDepsHash = "sha256-rHT8ZLBe3uO1NxrbVBdrh0fn9gvBVq4XE8Gfhcshq/E=";

  postInstall = ''
    install -D -t $out/etc/udev/rules.d \
      $out/lib/node_modules/particle-cli/assets/50-particle.rules
  '';

  dontNpmBuild = true;
  dontNpmPrune = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command Line Interface for Particle Cloud and devices";
    homepage = "https://github.com/particle-iot/particle-cli";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jess ];
    mainProgram = "particle";
  };
})
