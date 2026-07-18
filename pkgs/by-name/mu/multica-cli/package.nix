{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule rec {
  pname = "multica-cli";
  version = "0.3.43";

  src = fetchFromGitHub {
    owner = "multica-ai";
    repo = "multica";
    rev = "v${version}";
    hash = "sha256-XzJIWvSLK83f2ey7MKNvQuPuDy44dMf2YkxaudnLnvc=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-+IZt3ZQDHEcLA1cOcN4j4cTtIbATzAowUL3i1ZQnzBc=";
  env.CGO_ENABLED = 0;

  postInstall = ''
    installShellCompletion --cmd multica \
      --bash <($out/bin/multica completion bash) \
      --zsh <($out/bin/multica completion zsh) \
      --fish <($out/bin/multica completion fish)
  '';

  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
    "-X main.commit=nixpkg"
    "-X main.date=1970-01-01T00:00:00Z"
  ];

  sourceRoot = "${src.name}/server";
  subPackages = [ "cmd/multica" ];

  meta = {
    description = "CLI for the Multica managed agents platform";
    homepage = "https://github.com/multica-ai/multica";
    changelog = "https://github.com/multica-ai/multica/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ akosseres ];
    mainProgram = "multica";
  };
}
