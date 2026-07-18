{
  lib,
  fetchFromGitHub,
  buildGo126Module,
  installShellFiles,
  nix-update-script,
  nixosTests,
}:

buildGo126Module (finalAttrs: {
  pname = "miniflux";
  version = "2.3.2";

  src = fetchFromGitHub {
    owner = "miniflux";
    repo = "v2";
    tag = finalAttrs.version;
    hash = "sha256-gfudc11dJKzRtsT2gEazzgGFoUVaZNqgzdIATuGH29U=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-JjZfZJyml6/ANilLNAKaounUJ35TWhj/wVWWiGEhxps=";
  # skip tests that require network access
  checkFlags = [ "-skip=TestResolvesToPrivateIP" ];

  postInstall = ''
    mv $out/bin/miniflux.app $out/bin/miniflux
    installManPage miniflux.1
  '';

  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-s"
    "-w"
    "-X miniflux.app/v2/internal/version.Version=${finalAttrs.version}"
  ];

  passthru = {
    tests = nixosTests.miniflux;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Minimalist and opinionated feed reader";
    homepage = "https://miniflux.app/";
    changelog = "https://miniflux.app/releases/${finalAttrs.version}.html";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      rvolosatovs
      benpye
      emilylange
      adamcstephens
    ];

    mainProgram = "miniflux";
  };
})
