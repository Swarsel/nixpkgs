{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cmake,
  cython,
  ninja,
  pytestCheckHook,
  rapidfuzz,
  rapidfuzz-cpp,
  scikit-build-core,
}:

buildPythonPackage rec {
  pname = "levenshtein";
  version = "0.27.3";

  src = fetchFromGitHub {
    owner = "rapidfuzz";
    repo = "Levenshtein";
    tag = "v${version}";
    hash = "sha256-iKWS7gm0t3yPgeX5N09cTa3N1C6GXvIALueO8DlfLfE=";
  };

  # https://github.com/rapidfuzz/Levenshtein/pull/84
  patches = [ ./cython-3.2-compat.patch ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "Cython>=3.1.6,<3.2.0" Cython
  '';

  buildInputs = [ rapidfuzz-cpp ];
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    cmake
    cython
    ninja
    scikit-build-core
  ];

  dependencies = [ rapidfuzz ];
  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "Levenshtein" ];

  meta = {
    description = "Functions for fast computation of Levenshtein distance and string similarity";
    homepage = "https://github.com/rapidfuzz/Levenshtein";
    changelog = "https://github.com/rapidfuzz/Levenshtein/blob/v${version}/HISTORY.md";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ fab ];
  };
}
