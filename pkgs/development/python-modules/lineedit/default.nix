{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pexpect,
  ptyprocess,
  pygments,
  pyte,
  pytestCheckHook,
  six,
  wcwidth,
}:

buildPythonPackage rec {
  pname = "lineedit";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "randy3k";
    repo = "lineedit";
    rev = "v${version}";
    sha256 = "fq2NpjIQkIq1yzXEUxi6cz80kutVqcH6MqJXHtpTFsk=";
  };

  propagatedBuildInputs = [
    pygments
    six
    wcwidth
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pyte
    pexpect
    ptyprocess
  ];

  format = "setuptools";
  pythonImportsCheck = [ "lineedit" ];

  meta = {
    description = "Readline library based on prompt_toolkit which supports multiple modes";
    homepage = "https://github.com/randy3k/lineedit";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ savyajha ];
  };
}
