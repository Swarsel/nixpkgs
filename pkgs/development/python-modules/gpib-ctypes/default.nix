{
  lib,
  buildPythonPackage,
  fetchPypi,
  linux-gpib,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "gpib-ctypes";
  version = "0.3.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-c9l6TNmM4PtbvopnnFi5R1dQ9o3MI39BHHHPSGqfjCY=";
    pname = "gpib_ctypes";
  };

  postPatch = ''
    substituteInPlace gpib_ctypes/gpib/gpib.py \
      --replace "libgpib.so.0" "${linux-gpib}/lib/libgpib.so.0"
    substituteInPlace setup.py \
      --replace "'pytest-runner'," ""
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "gpib_ctypes.gpib" ];

  meta = {
    description = "Cross-platform Python bindings for the NI GPIB and linux-gpib C interfaces";
    homepage = "https://github.com/tivek/gpib_ctypes/";
    changelog = "https://github.com/tivek/gpib_ctypes/blob/${version}/HISTORY.rst";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ fsagbuya ];
  };
}
