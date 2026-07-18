{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch2,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage {
  pname = "yarg";
  version = "0.1.9-unstable-2022-02-06";

  src = fetchFromGitHub {
    owner = "kura";
    repo = "yarg";
    # Latest commit to yarg, which is more up-to-date than the latest release.
    rev = "46e2371906bde6e19116664d4841abab414c54fd";
    hash = "sha256-N/NDc9GqqwqU9vD1BU6udthzewBMDji9Np/HKRffLxI=";
  };

  patches = [
    # Python 3.12 compatibility patch
    (fetchpatch2 {
      hash = "sha256-2lbOzEfWTtoZYuRjCQJAFeYUsJoQhhEohflvYOwLXnI=";
      url = "https://github.com/kura/yarg/commit/8d5532e4da11ab0e9a4453658cf0591dcf80a616.patch?full_index=1";
    })
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;

  meta = {
    description = "Easy to use PyPI client";
    homepage = "https://yarg.readthedocs.io";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ psyanticy ];
  };
}
