{
  lib,
  buildPythonPackage,
  cryptography,
  uv-build,
}:

buildPythonPackage rec {
  # The test vectors must have the same version as the cryptography package
  inherit (cryptography) version src;
  pname = "cryptography-vectors";
  # No tests included
  doCheck = false;
  build-system = [ uv-build ];
  pyproject = true;
  pythonImportsCheck = [ "cryptography_vectors" ];
  sourceRoot = "${src.name}/vectors";

  meta = {
    description = "Test vectors for the cryptography package";
    homepage = "https://cryptography.io/en/latest/development/test-vectors/";

    license = with lib.licenses; [
      asl20
      bsd3
    ];

    maintainers = with lib.maintainers; [ mdaniels5757 ];
    downloadPage = "https://github.com/pyca/cryptography/tree/master/vectors";
  };
}
