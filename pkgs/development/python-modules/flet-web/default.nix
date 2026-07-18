{
  lib,
  buildPythonPackage,
  fastapi,
  flet,
  flet-client-flutter,
  # build-system
  poetry-core,
  python,
  uvicorn,
}:

buildPythonPackage rec {
  inherit (flet-client-flutter) version src;
  pname = "flet-web";

  postInstall = ''
    ln -s $web $out/${python.sitePackages}/flet_web/web
  '';

  build-system = [ poetry-core ];

  dependencies = [
    flet
    fastapi
    uvicorn
  ];

  pyproject = true;
  pythonImportsCheck = [ "flet_web" ];
  sourceRoot = "${src.name}/sdk/python/packages/flet-web";

  web = flet-client-flutter.override {
    fletTarget = "web";
  };

  meta = {
    description = "Flet web client in Flutter";
    homepage = "https://flet.dev/";
    changelog = "https://github.com/flet-dev/flet/releases/tag/v${version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      heyimnova
    ];
  };
}
