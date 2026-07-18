{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
}:

buildPythonPackage rec {
  pname = "absl-py";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "abseil";
    repo = "abseil-py";
    tag = "v${version}";
    hash = "sha256-U8doys7SoOhtUkF0dsCFKnM9ItOoi5a6cK6zGOe/U8s=";
  };

  # checks use bazel; should be revisited
  doCheck = false;
  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "absl" ];

  meta = {
    description = "Abseil Python Common Libraries";
    homepage = "https://github.com/abseil/abseil-py";
    changelog = "https://github.com/abseil/abseil-py/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
