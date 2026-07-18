{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "grin";
  version = "1.3.0-unstable-2023-08-30";

  src = fetchFromGitHub {
    owner = "matthew-brett";
    repo = "grin";
    rev = "00e11ebf17bbb37dc33d282eac1282c0bcc07e82";
    hash = "sha256-0lrCOXFb2v0hCxWd9O7ysbn8CjPd8NHOJhARYzJJcYg=";
  };

  nativeCheckInputs = [ python3Packages.pytestCheckHook ];
  build-system = [ python3Packages.setuptools ];
  namePrefix = "";
  pyproject = true;

  meta = {
    description = "Grep program configured the way I like it";
    homepage = "https://github.com/matthew-brett/grin";
    maintainers = [ lib.maintainers.sjagoe ];
    platforms = lib.platforms.all;
  };
}
