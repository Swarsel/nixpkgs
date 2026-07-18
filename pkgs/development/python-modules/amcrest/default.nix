{
  lib,
  fetchFromGitHub,
  argcomplete,
  buildPythonPackage,
  fetchpatch2,
  httpx,
  mock,
  pytestCheckHook,
  requests,
  responses,
  setuptools,
  typing-extensions,
  urllib3,
}:

buildPythonPackage rec {
  pname = "amcrest";
  version = "1.9.9";

  src = fetchFromGitHub {
    owner = "tchellomello";
    repo = "python-amcrest";
    tag = version;
    hash = "sha256-UPxs/sL8ZpUf29fpQFnLY4tV7qSQIxm0UVSl6Pm1dAY=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-i9UeYo43Eiwz06KfWyVQUPTLCJLmMjjNcjA7ZQcPIqQ=";
      # https://github.com/tchellomello/python-amcrest/pull/240
      name = "distutils-str2bool.patch";
      url = "https://github.com/tchellomello/python-amcrest/commit/9cced67d643da6c33d92e85dde22e01b44fb0936.patch";
    })
  ];

  nativeCheckInputs = [
    mock
    pytestCheckHook
    responses
  ];

  build-system = [ setuptools ];

  dependencies = [
    argcomplete
    httpx
    requests
    urllib3
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "amcrest" ];

  meta = {
    description = "Python module for Amcrest and Dahua Cameras";
    homepage = "https://github.com/tchellomello/python-amcrest";
    changelog = "https://github.com/tchellomello/python-amcrest/releases/tag/${src.tag}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
