{
  lib,
  buildPythonPackage,
  dos2unix,
  fetchPypi,
  pandas,
  pytestCheckHook,
  scipy,
  torch,
}:

buildPythonPackage rec {
  pname = "slicer";
  version = "0.0.8";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-LnVTr3PwwMLTVfSvzD7Pl8byFW/PRZOVXD9Wz2xNbrc=";
  };

  nativeBuildInputs = [ dos2unix ];

  nativeCheckInputs = [
    pytestCheckHook
    pandas
    torch
    scipy
  ];

  prePatch = ''
    dos2unix slicer/*
  '';

  pyproject = true;

  meta = {
    description = "Wraps tensor-like objects and provides a uniform slicing interface via __getitem__";
    homepage = "https://github.com/interpretml/slicer";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ evax ];
    platforms = lib.platforms.unix;
  };
}
