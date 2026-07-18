{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "marked-man";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "kapouer";
    repo = "marked-man";
    rev = version;
    hash = "sha256-RzPKahYxBdWZi1SwIv7Ju1cAQ4s0ANkCivFJItPYGCY=";
  };

  npmDepsHash = "sha256-8m0Xgq3O69hbSQArSrU/gbJvBEGP6rHK4to16QkXG6M=";
  dontNpmBuild = true;

  # https://github.com/kapouer/marked-man/issues/37
  prePatch = ''
    cp ${./package-lock.json} ./package-lock.json
  '';

  meta = {
    description = "Markdown to roff wrapper around marked";
    homepage = "https://github.com/kapouer/marked-man";
    changelog = "https://github.com/kapouer/marked-man/blob/${version}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ atemu ];
    platforms = lib.platforms.all;
    mainProgram = "marked-man";
  };
}
