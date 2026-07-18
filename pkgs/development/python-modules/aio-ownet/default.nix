{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "aio-ownet";
  version = "0.0.5";

  src = fetchFromGitHub {
    owner = "hacf-fr";
    repo = "aio-ownet";
    tag = "v${version}";
    hash = "sha256-KgQasltfoffVjCDX9s98qnZrv+VLiEffLi9FnUD5vXc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  optional-dependencies = {
    cli = [ click ];
  };

  pyproject = true;
  pythonImportsCheck = [ "aio_ownet" ];

  meta = {
    description = "Asynchronous OWFS (owserver network protocol) client library";
    homepage = "https://github.com/hacf-fr/aio-ownet";
    changelog = "https://github.com/hacf-fr/aio-ownet/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
