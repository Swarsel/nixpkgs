{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "helm-docs";
  version = "1.14.2";

  src = fetchFromGitHub {
    owner = "norwoodj";
    repo = "helm-docs";
    rev = "v${finalAttrs.version}";
    hash = "sha256-a7alzjh+vjJPw/g9yaYkOUvwpgiqCrtKTBkV1EuGYtk=";
  };

  vendorHash = "sha256-9VSjxnc804A+PTMy0ZoNWNkHAjh3/kMK0XoEfI/LgEY=";

  ldflags = [
    "-w"
    "-s"
    "-X main.version=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/helm-docs" ];

  meta = {
    description = "Tool for automatically generating markdown documentation for Helm charts";
    homepage = "https://github.com/norwoodj/helm-docs";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ sagikazarmark ];
    mainProgram = "helm-docs";
  };
})
