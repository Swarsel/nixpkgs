{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  elm-review,
  testers,
}:

buildNpmPackage rec {
  pname = "elm-review";
  version = "2.13.5";

  src = fetchFromGitHub {
    owner = "jfmengels";
    repo = "node-elm-review";
    rev = "v${version}";
    hash = "sha256-IjaPJ9ic/5Z8pdtziNwLqzXfnSmgkurjC6afmNIX4LU=";
  };

  postPatch = ''
    sed -i "s/elm-tooling install/echo 'skipping elm-tooling install'/g" package.json
  '';

  npmDepsHash = "sha256-eY9U9mLVL9tizN8touWQfLqFAJJ8pHaSHVD//cvNdhE=";
  dontNpmBuild = true;

  passthru.tests.version = testers.testVersion {
    version = "${version}";
    command = "elm-review --version";
    package = elm-review;
  };

  meta = {
    description = "Analyzes Elm projects, to help find mistakes before your users find them";
    homepage = "https://github.com/jfmengels/node-elm-review";
    changelog = "https://github.com/jfmengels/node-elm-review/blob/main/CHANGELOG.md";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      turbomack
      zupo
    ];

    mainProgram = "elm-review";
  };
}
