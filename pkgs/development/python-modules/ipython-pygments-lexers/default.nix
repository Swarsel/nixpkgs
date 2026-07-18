{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  pygments,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "ipython-pygments-lexers";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "ipython";
    repo = "ipython-pygments-lexers";
    tag = version;
    hash = "sha256-p2WrFvCzHOuxPec9Wc1/xT6+fEUdcdDC1HTNmu5dm5Q=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ flit-core ];
  dependencies = [ pygments ];
  pyproject = true;
  pythonImportsCheck = [ "ipython_pygments_lexers" ];

  meta = {
    description = "Pygments lexers for syntax-highlighting IPython code & sessions";
    homepage = "https://github.com/ipython/ipython-pygments-lexers";
    changelog = "https://github.com/ipython/ipython-pygments-lexers/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
  };
}
