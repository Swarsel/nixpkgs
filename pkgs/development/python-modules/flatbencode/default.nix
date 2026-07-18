{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hypothesis,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "flatbencode";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "acatton";
    repo = "flatbencode";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1/4w41E8IKygJTBcQOexiDytV6BvVBwIjajKz2uCfu8=";
  };

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "flatbencode" ];

  meta = {
    description = "Fast, safe and non-recursive implementation of Bittorrent bencoding";
    homepage = "https://github.com/acatton/flatbencode";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ambroisie ];
  };
})
