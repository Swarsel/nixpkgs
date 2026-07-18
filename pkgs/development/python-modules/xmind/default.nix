{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "xmind";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "zhuifengshen";
    repo = "xmind";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xC1WpHz2eHb5+xShM/QUQAIYnJNyK1EKWbTXJKhDwbQ=";
  };

  # Project thas no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "xmind" ];

  meta = {
    description = "Python module to create mindmaps";
    homepage = "https://github.com/zhuifengshen/xmind";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
})
