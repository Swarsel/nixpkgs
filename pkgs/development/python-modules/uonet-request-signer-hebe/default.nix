{
  lib,
  buildPythonPackage,
  fetchPypi,
  pyopenssl,
}:

buildPythonPackage rec {
  pname = "uonet-request-signer-hebe";
  version = "0.1.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "fidopnpAt5CXPsLbx+V8wrJCQQ/WIO6AqxpsYLDv8qM=";
  };

  propagatedBuildInputs = [ pyopenssl ];
  # Source is not tagged
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "uonet_request_signer_hebe" ];

  meta = {
    description = "UONET+ (hebe) request signer for Python";
    homepage = "https://github.com/wulkanowy/uonet-request-signer";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
