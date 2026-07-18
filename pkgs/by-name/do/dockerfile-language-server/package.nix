{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "dockerfile-language-server";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "rcjsuen";
    repo = "dockerfile-language-server";
    tag = "v${version}";
    hash = "sha256-olgOUbVHHj9vD7upswqVJYBRIRb+kg6uXC2y5shnM+g=";
  };

  npmDepsHash = "sha256-cJ11l2NF/sCzPw/eQNFon5oKRM+KPoy4lxLz0yivHTo=";

  preBuild = ''
    npm run prepublishOnly
  '';

  meta = {
    description = "Language server for Dockerfiles powered by Node.js, TypeScript, and VSCode technologies";
    homepage = "https://github.com/rcjsuen/dockerfile-language-server";
    changelog = "https://github.com/rcjsuen/dockerfile-language-server/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      rvolosatovs
      net-mist
      dlugoschvincent
    ];

    mainProgram = "docker-langserver";
  };
}
