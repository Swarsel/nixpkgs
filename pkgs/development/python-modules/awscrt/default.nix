{
  lib,
  stdenv,
  buildPythonPackage,
  cmake,
  fetchPypi,
  perl,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "awscrt";
  version = "0.33.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-K0wP8DsZQmeNhvcJQ0LeyUZLTfC6PjaSsoQXyVuVp9s=";
  };

  nativeBuildInputs = [ cmake ] ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [ perl ];
  # Unable to import test module
  # https://github.com/awslabs/aws-crt-python/issues/281
  doCheck = false;
  build-system = [ setuptools ];
  dontUseCmakeConfigure = true;
  hardeningDisable = [ "fortify" ]; # needed for jitterentropy
  pyproject = true;
  pythonImportsCheck = [ "awscrt" ];

  meta = {
    description = "Python bindings for the AWS Common Runtime";
    homepage = "https://github.com/awslabs/aws-crt-python";
    changelog = "https://github.com/awslabs/aws-crt-python/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ davegallant ];
  };
})
