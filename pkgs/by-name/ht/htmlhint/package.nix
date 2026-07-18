{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "htmlhint";
  version = "1.9.2";

  src = fetchFromGitHub {
    owner = "htmlhint";
    repo = "HTMLHint";
    rev = "v${version}";
    hash = "sha256-jqlTtLC9tCGVU9w5xC3Lgr61SOo96yk2rIG0LjYGklw=";
  };

  npmDepsHash = "sha256-baMVZNwKwXVQCkIgaQizYe9vjYKJXggUXsGMZmSrwdY=";

  meta = {
    description = "Static code analysis tool for HTML";
    homepage = "https://github.com/htmlhint/HTMLHint";
    changelog = "https://github.com/htmlhint/HTMLHint/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "htmlhint";
  };
}
