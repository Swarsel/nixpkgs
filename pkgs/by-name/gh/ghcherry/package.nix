{
  lib,
  fetchFromGitHub,
  python3Packages,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "ghcherry";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "PerchunPak";
    repo = "ghcherry";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yUsYf0v5IZh4yxkG+nu8cG4L/WcJTFDefc//l4v36sY=";
  };

  nativeCheckInputs = with python3Packages; [
    faker
    pytest-asyncio
    pytest-cov-stub
    pytest-httpx
    pytest-mock
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = with python3Packages; [
    hatchling
    uv-dynamic-versioning
  ];

  dependencies = with python3Packages; [
    cyclopts
    httpx
  ];

  pyproject = true;
  pythonImportsCheck = [ "ghcherry" ];
  # upstream has strict dependency pins, but it doesn't break with slightly
  # newer/older versions
  #   (c) upstream maintainer
  pythonRelaxDeps = true;

  meta = {
    description = "Cherry-pick commits across GitHub repositories using only the GitHub API";
    homepage = "https://github.com/PerchunPak/ghcherry";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.PerchunPak ];
    mainProgram = "ghcherry";
  };
})
