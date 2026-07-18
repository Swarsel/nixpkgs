{
  lib,
  fetchFromGitHub,
  maven,
  nix-update-script,
}:
maven.buildMavenPackage (finalAttrs: {
  pname = "keycloak-home-idp-discovery";
  version = "26.2.1";

  src = fetchFromGitHub {
    owner = "sventorben";
    repo = "keycloak-home-idp-discovery";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4zZVDl50LOYv6OeBsBevxM9u3PNQPrn4ZxSNTa8dN7M=";
  };

  strictDeps = true;

  installPhase = ''
    runHook preInstall
    install -Dm444 -t "$out" target/keycloak-home-idp-discovery.jar
    runHook postInstall
  '';

  __structuredAttrs = true;
  mvnHash = "sha256-+Urd07v2mYQjPCGAP4OnJr/dE/lmLrq8M7RAEdhyX3Y=";
  # e2e tests need docker (testcontainers/selenium)
  mvnParameters = "-DskipTests";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Keycloak authenticator to redirect users to their home identity provider by email domain";
    homepage = "https://github.com/sventorben/keycloak-home-idp-discovery";
    changelog = "https://github.com/sventorben/keycloak-home-idp-discovery/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ anish ];
  };
})
