{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:
buildNpmPackage (finalAttrs: {
  pname = "yaml-language-server";
  version = "1.24.0";

  src = fetchFromGitHub {
    owner = "redhat-developer";
    repo = "yaml-language-server";
    tag = finalAttrs.version;
    hash = "sha256-JIThwWGunUn4fHxPx7wBqi/F9aslNhWjcx11TvMyoDQ=";
  };

  strictDeps = true;
  npmDepsHash = "sha256-0jmq/4XpuZLjoRCxpGBZdGgfyvBTBBoT893o2mooCVw=";

  meta = {
    description = "Language Server for YAML Files";
    homepage = "https://github.com/redhat-developer/yaml-language-server";
    changelog = "https://github.com/redhat-developer/yaml-language-server/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      nick-linux
    ];

    mainProgram = "yaml-language-server";
  };
})
