{
  lib,
  fetchFromGitLab,
  buildGoModule,
  nix-update-script,
}:
let
  version = "1.2";
in
buildGoModule {
  inherit version;
  pname = "invidious-router";

  src = fetchFromGitLab {
    owner = "gaincoder";
    repo = "invidious-router";
    tag = version;
    hash = "sha256-YcMtZq4VMHr6XqHcsAAEmMF6jF1j1wb7Lq4EK42QAEo=";
  };

  vendorHash = "sha256-c03vYidm8SkoesRVQZdg/bCp9LIpdTmpXdfwInlHBKk=";
  doCheck = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Go application that routes requests to different Invidious instances based on their health status and (optional) response time";
    homepage = "https://gitlab.com/gaincoder/invidious-router";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ sils ];
    mainProgram = "invidious-router";
  };
}
