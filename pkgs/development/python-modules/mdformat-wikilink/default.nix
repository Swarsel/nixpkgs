{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  markdown-it-py,
  mdformat,
  poetry-core,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "mdformat-wikilink";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "tmr232";
    repo = "mdformat-wikilink";
    tag = "v${version}";
    hash = "sha256-tYUF5gNmXjzlf0jQg0tL2ayFGCSFFeYJHkWA6cYLpvI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ poetry-core ];

  dependencies = [
    markdown-it-py
    mdformat
  ];

  pyproject = true;
  pythonImportsCheck = [ "mdformat_wikilink" ];

  meta = {
    description = "Mdformat plugin for ensuring that wiki-style links are preserved during formatting";
    homepage = "https://github.com/tmr232/mdformat-wikilink";
    changelog = "https://github.com/tmr232/mdformat-wikilink/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mattkang ];
  };
}
