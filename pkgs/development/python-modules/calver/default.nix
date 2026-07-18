{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pretend,
  pytestCheckHook,
  setuptools,
}:

let
  self = buildPythonPackage rec {
    pname = "calver";
    version = "2025.10.20";

    src = fetchFromGitHub {
      owner = "di";
      repo = "calver";
      tag = version;
      hash = "sha256-8CfPQ4uMgKDqMMgutLdsjn/MaAVBJQAp1KqUfxzNMQw=";
    };

    postPatch = ''
      substituteInPlace setup.py \
        --replace "version=calver_version(True)" 'version="${version}"'
    '';

    doCheck = false; # avoid infinite recursion with hatchling

    nativeCheckInputs = [
      pretend
      pytestCheckHook
    ];

    build-system = [ setuptools ];
    pyproject = true;
    pythonImportsCheck = [ "calver" ];
    passthru.tests.calver = self.overridePythonAttrs { doCheck = true; };

    meta = {
      description = "Setuptools extension for CalVer package versions";
      homepage = "https://github.com/di/calver";
      changelog = "https://github.com/di/calver/releases/tag/${src.tag}";
      license = lib.licenses.asl20;
      maintainers = with lib.maintainers; [ dotlambda ];
    };
  };
in
self
