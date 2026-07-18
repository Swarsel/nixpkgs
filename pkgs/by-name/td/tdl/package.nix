{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule (finalAttrs: {
  pname = "tdl";
  version = "0.20.3";

  src = fetchFromGitHub {
    owner = "iyear";
    repo = "tdl";
    rev = "v${finalAttrs.version}";
    hash = "sha256-uVg4SXq+E+pzKFzCt7nn99sTCLj7CXaWnjIidKPA2Kk=";
  };

  postPatch = ''
    rm go.work go.work.sum
    go mod edit -replace github.com/iyear/tdl/core=./core
    go mod edit -replace github.com/iyear/tdl/extension=./extension
  '';

  vendorHash = "sha256-tg6GQ3SVDJnKUCrOuI+iJ/cJeiNNki9+ZF21r0t5rQA=";
  buildFlags = [ "-p=1" ];
  env.GOGC = "50";
  # Requires network access
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/iyear/tdl/pkg/consts.Version=${finalAttrs.version}"
  ];

  # Filter out the main executable
  subPackages = [ "." ];

  meta = {
    description = "Telegram downloader/tools written in Golang";
    homepage = "https://github.com/iyear/tdl";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ Ligthiago ];
    mainProgram = "tdl";
  };
})
