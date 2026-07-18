{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "go-minimock";
  version = "3.4.7";

  src = fetchFromGitHub {
    owner = "gojuno";
    repo = "minimock";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Dx4m17r7GOdiaV8DzqOXAr32dNCXJyi7gID6GHohKXk=";
  };

  vendorHash = "sha256-74bmsixBO5VwLZYRXN9Fx3Mu9BbL4bSF6o0h9QaET1Y=";
  doCheck = true;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  subPackages = [
    "cmd/minimock"
    "."
  ];

  meta = {
    description = "Golang mock generator from interfaces";
    homepage = "https://github.com/gojuno/minimock";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ svrana ];
    mainProgram = "minimock";
  };
})
