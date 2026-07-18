{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatchling,
  # dependencies
  protobuf,
  requests,
}:

buildPythonPackage (finalAttrs: {
  pname = "kagglesdk";
  version = "0.1.30";

  src = fetchFromGitHub {
    owner = "Kaggle";
    repo = "kagglesdk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7YjbJ6uo6R3jpo25wlHftYAA+0t7oUXc432N/REeCzU=";
  };

  # The two available tests fail with:
  # AssertionError: 'https://api.kaggle.com' != 'https://www.kaggle.com'
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    hatchling
  ];

  dependencies = [
    protobuf
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "kagglesdk" ];

  meta = {
    description = "Bindings to access Kaggle endpoints";
    homepage = "https://github.com/Kaggle/kagglesdk";
    changelog = "https://github.com/Kaggle/kagglesdk/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
