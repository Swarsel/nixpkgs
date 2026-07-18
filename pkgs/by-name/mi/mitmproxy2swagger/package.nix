{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "mitmproxy2swagger";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "alufers";
    repo = "mitmproxy2swagger";
    tag = finalAttrs.version;
    hash = "sha256-J5vuT0p+mc1XXEl7GnXbT/J4mTjzva66o3cUizBWMko=";
  };

  # No tests available
  doCheck = false;
  build-system = with python3.pkgs; [ hatchling ];

  dependencies = with python3.pkgs; [
    json-stream
    mitmproxy
    ruamel-yaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "mitmproxy2swagger" ];

  pythonRelaxDeps = [
    "mitmproxy"
    "ruamel.yaml"
  ];

  meta = {
    description = "Tool to automagically reverse-engineer REST APIs";
    homepage = "https://github.com/alufers/mitmproxy2swagger";
    changelog = "https://github.com/alufers/mitmproxy2swagger/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "mitmproxy2swagger";
  };
})
