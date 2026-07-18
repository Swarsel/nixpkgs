{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fsspec,
  numpy,
  pandas,
  pyarrow,
  pytestCheckHook,
  tqdm,
}:

buildPythonPackage rec {
  pname = "embedding-reader";
  version = "1.8.1";

  src = fetchFromGitHub {
    owner = "rom1504";
    repo = "embedding-reader";
    tag = version;
    hash = "sha256-D7yrvV6hDqzHaIMhCQ16DhY/8FEr3P4gcT5vV371whs=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  dependencies = [
    fsspec
    numpy
    pandas
    pyarrow
    tqdm
  ];

  format = "setuptools";
  pythonImportsCheck = [ "embedding_reader" ];
  pythonRelaxDeps = [ "pyarrow" ];

  meta = {
    description = "Efficiently read embedding in streaming from any filesystem";
    homepage = "https://github.com/rom1504/embedding-reader";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ samuela ];
  };
}
