{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  matplotlib,
  numpy,
  pytestCheckHook,
  requests,
  scipy,
  seaborn,
  setuptools,
}:

buildPythonPackage rec {
  pname = "simpful";
  version = "2.12.0";

  src = fetchFromGitHub {
    owner = "aresio";
    repo = "simpful";
    tag = version;
    hash = "sha256-NtTw7sF1WfVebUk1wHrM8FHAe3/FXDcMApPkDbw0WXo=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    numpy
    scipy
    requests
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  optional-dependencies = {
    plotting = [
      matplotlib
      seaborn
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "simpful" ];

  meta = {
    description = "Library for fuzzy logic";
    homepage = "https://github.com/aresio/simpful";
    changelog = "https://github.com/aresio/simpful/releases/tag/${version}";
    license = with lib.licenses; [ lgpl3Only ];
    maintainers = with lib.maintainers; [ fab ];
    broken = stdenv.hostPlatform.isDarwin;
  };
}
