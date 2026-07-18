{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cython,
  # tests
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "affinegap";
  version = "1.12";

  src = fetchFromGitHub {
    owner = "dedupeio";
    repo = "affinegap";
    tag = "v${version}";
    hash = "sha256-9eX41eoME5Vdtq+c04eQbMYnViy6QKOhKkafrkeMylI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  # Prevent importing from source during test collection (only $out has compiled extensions)
  preCheck = ''
    rm -rf affinegap
  '';

  build-system = [
    cython
    setuptools
  ];

  pyproject = true;

  pythonImportsCheck = [
    "affinegap"
  ];

  # Bulk updater will see an older tag ending with a "2" and switch to it
  passthru.skipBulkUpdate = true;

  meta = {
    description = "Cython implementation of the affine gap string distance";
    homepage = "https://github.com/dedupeio/affinegap";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ daniel-fahey ];
  };
}
