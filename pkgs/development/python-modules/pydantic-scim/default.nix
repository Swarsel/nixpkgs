{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pydantic,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pydantic-scim";
  version = "0.0.8";

  src = fetchFromGitHub {
    owner = "chalk-ai";
    repo = "pydantic-scim";
    tag = "v${version}";
    hash = "sha256-Hbc94v/+slXRGDKKbMui8WPwn28/1XcKvHkbLebWtj0=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace 'version=get_version(),' 'version="${version}",'
  '';

  nativeBuildInputs = [
    setuptools
    setuptools-scm
  ];

  propagatedBuildInputs = [ pydantic ] ++ pydantic.optional-dependencies.email;
  # no tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "pydanticscim" ];

  meta = {
    description = "Pydantic types for SCIM";
    homepage = "https://github.com/chalk-ai/pydantic-scim";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
