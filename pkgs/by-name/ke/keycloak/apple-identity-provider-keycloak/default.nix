{
  lib,
  stdenv,
  fetchFromGitHub,
  gradle_8,
  nix-update-script,
}:
let
  gradle = gradle_8;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "apple-identity-provider-keycloak";
  version = "1.17.0";

  src = fetchFromGitHub {
    owner = "klausbetz";
    repo = "apple-identity-provider-keycloak";
    tag = finalAttrs.version;
    hash = "sha256-0/uHQwgyHwy+5ynRHs0ot0iIBVUckEs65YxkWLQNgbY=";
  };

  strictDeps = true;
  nativeBuildInputs = [ gradle ];

  installPhase = ''
    runHook preInstall
    install -Dm444 -t "$out" build/libs/apple-identity-provider-${finalAttrs.version}.jar
    runHook postInstall
  '';

  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;

  mitmCache = gradle.fetchDeps {
    data = ./deps.json;
    pkg = finalAttrs.finalPackage;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Keycloak identity provider extension for Sign in with Apple";
    homepage = "https://github.com/klausbetz/apple-identity-provider-keycloak";
    changelog = "https://github.com/klausbetz/apple-identity-provider-keycloak/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # mitm cache
    ];

    maintainers = with lib.maintainers; [ anish ];
    platforms = lib.platforms.unix;
  };
})
