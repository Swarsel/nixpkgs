{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  pytest,
  # tests
  pytestCheckHook,
  # build-system
  uv-build,
}:

let
  pname = "pytest-describe";
  version = "3.2.0";
in
buildPythonPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "pytest-dev";
    repo = "pytest-describe";
    tag = version;
    hash = "sha256-nvTINE3QtV2pCKD/aixYDSO2ryW1uYDv55FLOMP7Vlc=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.9.4,<0.10.0" uv_build
  '';

  buildInputs = [ pytest ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ uv-build ];
  pyproject = true;

  meta = {
    description = "Describe-style plugin for the pytest framework";
    homepage = "https://github.com/pytest-dev/pytest-describe";
    changelog = "https://github.com/pytest-dev/pytest-describe/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
