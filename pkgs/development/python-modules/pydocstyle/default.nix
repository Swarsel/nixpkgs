{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch2,
  poetry-core,
  pytestCheckHook,
  snowballstemmer,
  tomli,
}:

buildPythonPackage rec {
  pname = "pydocstyle";
  version = "6.3.0";

  src = fetchFromGitHub {
    owner = "PyCQA";
    repo = "pydocstyle";
    tag = version;
    hash = "sha256-MjRrnWu18f75OjsYIlOLJK437X3eXnlW8WkkX7vdS6k=";
  };

  patches = [
    # https://github.com/PyCQA/pydocstyle/pull/656
    (fetchpatch2 {
      hash = "sha256-bqnoLz1owzDpFqlZn8z4Z+RzKCYBsI0PqqeOtjLxnMo=";
      name = "python312-compat.patch";
      url = "https://github.com/PyCQA/pydocstyle/commit/306c7c8f2d863bdc098a65d2dadbd4703b9b16d5.patch";
    })
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'version = "0.0.0-dev"' 'version = "${version}"'
  '';

  nativeBuildInputs = [ poetry-core ];
  propagatedBuildInputs = [ snowballstemmer ];
  nativeCheckInputs = [ pytestCheckHook ] ++ optional-dependencies.toml;

  disabledTestPaths = [
    "src/tests/test_integration.py" # runs pip install
  ];

  optional-dependencies.toml = [ tomli ];
  pyproject = true;

  meta = {
    description = "Python docstring style checker";
    homepage = "https://github.com/PyCQA/pydocstyle";
    changelog = "https://github.com/PyCQA/pydocstyle/blob/${version}/docs/release_notes.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dzabraev ];
    mainProgram = "pydocstyle";
  };
}
