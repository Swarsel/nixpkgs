{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "newman";
  version = "6.2.2";

  src = fetchFromGitHub {
    owner = "postmanlabs";
    repo = "newman";
    tag = "v${version}";
    hash = "sha256-zp5x/eMF5MPpWrbqDt2t5p5LGx2g58hr+uySLRN3vR4=";
  };

  npmDepsHash = "sha256-Es4Pu3XG9qQiCpYJMIfhKiqCGb4R4Focu/2ol4qRiW8=";
  dontNpmBuild = true;

  meta = {
    description = "Command-line collection runner for Postman";
    homepage = "https://www.getpostman.com";
    changelog = "https://github.com/postmanlabs/newman/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "newman";
  };
}
