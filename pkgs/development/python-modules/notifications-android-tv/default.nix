{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  poetry-core,
  pytest-asyncio,
  pytest-httpx,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "notifications-android-tv";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "engrbm87";
    repo = "notifications_android_tv";
    tag = version;
    hash = "sha256-JUvxxVCiQtywAWU5AYnPm4SueIWIXkzLxPYveVXpc2E=";
  };

  nativeBuildInputs = [ poetry-core ];
  propagatedBuildInputs = [ httpx ];
  nativeCheckInputs = [ pytestCheckHook ];

  checkInputs = [
    pytest-asyncio
    pytest-httpx
  ];

  pyproject = true;
  pythonImportsCheck = [ "notifications_android_tv" ];
  pythonRelaxDeps = [ "httpx" ];

  meta = {
    description = "Python API for sending notifications to Android/Fire TVs";
    homepage = "https://github.com/engrbm87/notifications_android_tv";
    changelog = "https://github.com/engrbm87/notifications_android_tv/blob/${version}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dominikh ];
  };
}
