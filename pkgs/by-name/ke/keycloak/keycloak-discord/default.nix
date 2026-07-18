{
  lib,
  stdenv,
  fetchFromGitHub,
  maven,
}:
maven.buildMavenPackage rec {
  pname = "keycloak-discord";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "iForged";
    repo = "keycloak-discord";
    tag = "v${version}";
    hash = "sha256-xTGXETkE5Ct+h3mYbj3VUoQhi5Wx5oZqz3G1uN0pDns=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm444 -t "$out" target/keycloak-discord-${version}.jar
    runHook postInstall
  '';

  mvnHash = "sha256-zFsVRFFGrHvTFW6+Y1o2OVFaf34JgqPVv+vMAfkSOJw=";

  meta = {
    description = "Keycloak Identity Provider extension for Discord";
    homepage = "https://github.com/iForged/keycloak-discord";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      mkg20001
      anish
    ];
  };
}
