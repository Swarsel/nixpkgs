{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  wcwidth,
}:

buildPythonPackage (finalAttrs: {
  pname = "tabulate";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "astanin";
    repo = "python-tabulate";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JnwkABtIgPqANuv3lo8e8zr8m6a/qnxz4w1QvTVZFxg=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-scm
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.concatAttrValues finalAttrs.finalPackage.optional-dependencies;

  optional-dependencies = {
    widechars = [ wcwidth ];
  };

  pyproject = true;

  meta = {
    description = "Pretty-print tabular data";
    homepage = "https://github.com/astanin/python-tabulate";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
    mainProgram = "tabulate";
  };
})
