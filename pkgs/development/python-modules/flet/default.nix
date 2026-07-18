{
  lib,
  buildPythonPackage,
  cookiecutter,
  # dependencies
  fastapi,
  flet-client-flutter,
  httpx,
  msgpack,
  # tests
  numpy,
  oauthlib,
  packaging,
  pillow,
  pytest-asyncio,
  pytestCheckHook,
  qrcode,
  repath,
  scikit-image,
  # build-system
  setuptools,
  uvicorn,
  watchdog,
  websocket-client,
  websockets,
}:

buildPythonPackage rec {
  inherit (flet-client-flutter) version src;
  pname = "flet";

  postPatch = ''
     # nerf out nagging about pip
    echo "$_flet_version" > src/flet/version.py
    echo "$_flet_utils_pip" >> src/flet/utils/pip.py
  '';

  nativeCheckInputs = [
    numpy
    pillow
    pytest-asyncio
    pytestCheckHook
    scikit-image
  ];

  _flet_utils_pip = ''
    def install_flet_package(name: str):
      pass
  '';

  _flet_version = ''
    flet_version = "${version}"
    def update_version():
      pass
  '';

  build-system = [ setuptools ];

  dependencies = [
    cookiecutter
    fastapi
    httpx
    msgpack
    oauthlib
    packaging
    qrcode
    repath
    uvicorn
    watchdog
    websocket-client
    websockets
  ];

  makeWrapperArgs = [
    "--prefix"
    "PYTHONPATH"
    ":"
    "$PYTHONPATH"
  ];

  pyproject = true;
  pythonImportsCheck = [ "flet" ];
  sourceRoot = "${src.name}/sdk/python/packages/flet";

  meta = {
    description = "Framework that enables you to easily build realtime web, mobile, and desktop apps in Python";
    homepage = "https://flet.dev/";
    changelog = "https://github.com/flet-dev/flet/releases/tag/v${version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      heyimnova
    ];

    mainProgram = "flet";
    broken = true;
  };
}
