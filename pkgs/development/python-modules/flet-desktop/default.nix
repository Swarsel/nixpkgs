{
  lib,
  buildPythonPackage,
  flet,
  flet-client-flutter,
  # build-system
  poetry-core,
}:

buildPythonPackage rec {
  inherit (flet-client-flutter) version src;
  pname = "flet-desktop";

  postPatch = ''
    echo "$_flet_setup_view" >> src/flet_desktop/__init__.py
  '';

  _flet_setup_view = ''
    if 'FLET_VIEW_PATH' not in os.environ:
      os.environ['FLET_VIEW_PATH'] = '${flet-client-flutter}/bin'
  '';

  build-system = [ poetry-core ];
  dependencies = [ flet ];
  pyproject = true;
  pythonImportsCheck = [ "flet_desktop" ];
  sourceRoot = "${src.name}/sdk/python/packages/flet-desktop";

  meta = {
    description = "Compiled Flutter Flet desktop client";
    homepage = "https://flet.dev/";
    changelog = "https://github.com/flet-dev/flet/releases/tag/v${version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      heyimnova
    ];
  };
}
