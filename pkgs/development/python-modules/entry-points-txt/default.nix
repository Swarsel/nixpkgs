{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "entry-points-txt";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "jwodder";
    repo = "entry-points-txt";
    tag = "v${version}";
    hash = "sha256-8oGK7aIDgXkCLh/d38hWzfF367KhmggG2s820D2r/EA=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "entry_points_txt" ];

  meta = {
    description = "Read & write entry_points.txt files";
    homepage = "https://github.com/jwodder/entry-points-txt";
    changelog = "https://github.com/wheelodex/entry-points-txt/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ayazhafiz ];
  };
}
