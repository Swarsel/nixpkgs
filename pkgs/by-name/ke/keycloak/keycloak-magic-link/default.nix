{
  lib,
  fetchFromGitHub,
  maven,
  nix-update-script,
}:
maven.buildMavenPackage rec {
  pname = "keycloak-magic-link";
  version = "0.52";

  src = fetchFromGitHub {
    owner = "p2-inc";
    repo = "keycloak-magic-link";
    tag = "v${version}";
    hash = "sha256-giKhcK/bRSYUfix0ttuk9gs2q3A+4dDlayN15tuJhcY=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 target/keycloak-magic-link-${version}.jar $out/keycloak-magic-link-${version}.jar
    runHook postInstall
  '';

  mvnHash = "sha256-x9o83Azzep27jQXjxJoTga6B+mELSAtho568yHKz42k=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Magic Link Authentication for Keycloak";
    homepage = "https://github.com/p2-inc/keycloak-magic-link";
    license = lib.licenses.elastic20;

    maintainers = with lib.maintainers; [
      lykos153
      anish
    ];
  };
}
