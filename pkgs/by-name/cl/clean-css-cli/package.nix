{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:
buildNpmPackage (finalAttrs: {
  pname = "clean-css-cli";
  version = "5.6.3";

  src = fetchFromGitHub {
    owner = "clean-css";
    repo = "clean-css-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tsFNcQg55uY2gL5xLLLS6INLlYzbsU6M3hnsYeOFGEw=";
  };

  npmDepsHash = "sha256-uvI9esVVOE18syHUCJpoiDY+Vh3hJO+GsMOTZSYJaxg=";
  dontCheckForBrokenSymlinks = true;
  dontNpmBuild = true;

  meta = {
    description = "Command-line interface to the clean-css CSS optimization library";
    homepage = "https://github.com/clean-css/clean-css-cli";
    changelog = "https://github.com/clean-css/clean-css-cli/blob/v${finalAttrs.version}/History.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "cleancss";
  };
})
