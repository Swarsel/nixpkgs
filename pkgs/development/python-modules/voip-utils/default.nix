{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  opuslib-next,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "voip-utils";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "home-assistant-libs";
    repo = "voip-utils";
    tag = "v${version}";
    hash = "sha256-kvuNqiBjcDQ53X6LbnOp2WNh8QOu+ExjhfgKWBoSsH0=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "~=" ">="
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ opuslib-next ];
  pyproject = true;
  pythonImportsCheck = [ "voip_utils" ];
  pythonRelaxDeps = [ "opuslib-next" ];

  meta = {
    description = "Voice over IP Utilities";
    homepage = "https://github.com/home-assistant-libs/voip-utils";
    changelog = "https://github.com/home-assistant-libs/voip-utils/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
