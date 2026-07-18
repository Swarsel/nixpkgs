{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  fire,
  python,
  python-crfsuite,
  setuptools,
  tqdm,
  unittestCheckHook,
}:

buildPythonPackage {
  pname = "ssg";
  version = "0.0.8";

  src = fetchFromGitHub {
    owner = "ponrawee";
    repo = "ssg";
    rev = "d1b811ef4f8ac08ba1db839f426ba6b6a8e0eb38";
    hash = "sha256-GBZzVDDfKOTnbcrIxhFRiNHXN2pSNU3T9RvUytJ068w=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-4O1fpI0FBUG/3RN+PAi7I8vpgYmPPL5ZMXhoZUFsQy8=";
      name = "fix-deprecation-warnings-and-bump-version";
      url = "https://patch-diff.githubusercontent.com/raw/ponrawee/ssg/pull/10.patch";
    })
  ];

  nativeCheckInputs = [ unittestCheckHook ];
  postInstall = "rm -rf $out/${python.sitePackages}/scripts";
  build-system = [ setuptools ];

  dependencies = [
    fire
    python-crfsuite
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "ssg" ];

  meta = {
    description = "TCRF syllable segmenter for Thai";
    homepage = "https://github.com/ponrawee/ssg";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ vizid ];
    mainProgram = "ssg-cli";
  };
}
