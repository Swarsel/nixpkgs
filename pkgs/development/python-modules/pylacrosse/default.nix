{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mock,
  pyserial,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pylacrosse";
  version = "0.5";

  src = fetchFromGitHub {
    owner = "hthiery";
    repo = "python-lacrosse";
    tag = finalAttrs.version;
    hash = "sha256-z2OlYFFK/+BONg22+Vk0kQQ0KJoQnRkjP7OUS/TVpfI=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "version = version," "version = '${finalAttrs.version}',"
  '';

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ];

  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ pyserial ];
  pyproject = true;
  pythonImportsCheck = [ "pylacrosse" ];

  meta = {
    description = "Python library for Jeelink LaCrosse";
    homepage = "https://github.com/hthiery/python-lacrosse";
    license = with lib.licenses; [ lgpl2Plus ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "pylacrosse";
  };
})
