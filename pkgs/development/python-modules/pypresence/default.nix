{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:
let
  version = "4.6.1";
in
buildPythonPackage {
  inherit version;
  pname = "pypresence";

  src = fetchFromGitHub {
    owner = "qwertyquerty";
    repo = "pypresence";
    tag = "v${version}";
    hash = "sha256-VvVHJ3S+Yusq4cK4KyDQlnL3VwAyrZqNKYzEgJPU8Vk=";
  };

  doCheck = false; # tests require internet connection
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pypresence" ];

  meta = {
    description = "Discord RPC client written in Python";
    homepage = "https://qwertyquerty.github.io/pypresence/html/index.html";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
