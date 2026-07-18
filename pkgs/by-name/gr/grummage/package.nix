{
  lib,
  fetchFromGitHub,
  grype,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "grummage";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "popey";
    repo = "grummage";
    tag = "v${finalAttrs.version}";
    hash = "sha256-K5/k4wSl2Ary9McPaK+T6nHqvIULuUcB3emJ7EibQrs=";
  };

  # no included tests or version flag
  doCheck = false;

  build-system = [
    python3Packages.hatchling
  ];

  dependencies = [
    python3Packages.textual
  ];

  makeWrapperArgs = [ "--suffix PATH : ${lib.makeBinPath [ grype ]}" ];
  pyproject = true;

  meta = {
    description = "Interactive terminal frontend to Grype";
    homepage = "https://github.com/popey/grummage";
    changelog = "https://github.com/popey/grummage/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
    mainProgram = "grummage";
  };
})
