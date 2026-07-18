{
  lib,
  fetchFromGitHub,
  buildGoModule,
  go-mockery_2,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "git-team";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "hekmekk";
    repo = "git-team";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0nDt4i6RK6/guLVNpgZE1HRJjIu9YIzaA296s5aAKF4=";
  };

  nativeBuildInputs = [
    go-mockery_2
    installShellFiles
  ];

  vendorHash = "sha256-5rS4EgY4x6zSoBF4ylg4R9rcI6Ia5bmx04k+Bc+8PlQ=";

  preBuild = ''
    mockery --dir=src/ --all --keeptree
  '';

  postInstall = ''
    go run main.go --generate-man-page > git-team.1
    installManPage git-team.1

    installShellCompletion --cmd git-team \
      --bash <($out/bin/git-team completion bash) \
      --zsh <($out/bin/git-team completion zsh)
  '';

  proxyVendor = true;

  meta = {
    description = "Command line interface for managing and enhancing git commit messages with co-authors";
    homepage = "https://github.com/hekmekk/git-team";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lockejan ];
    mainProgram = "git-team";
  };
})
