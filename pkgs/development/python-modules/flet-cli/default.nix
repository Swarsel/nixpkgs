{
  lib,
  buildPythonPackage,
  flet,
  flet-client-flutter,
  flet-desktop,
  flet-web,
  # build-system
  poetry-core,
  qrcode,
  toml,
  watchdog,
}:

buildPythonPackage rec {
  inherit (flet-client-flutter) version src;
  pname = "flet-cli";

  postInstall = ''
    mkdir -p $out/bin
    makeWrapper ${flet}/bin/flet $out/bin/flet \
      --prefix PYTHONPATH : $PYTHONPATH
  '';

  build-system = [ poetry-core ];

  dependencies = [
    flet
    flet-desktop
    flet-web
    qrcode
    toml
    watchdog
  ];

  makeWrapperArgs = [
    "--prefix"
    "PYTHONPATH"
    ":"
    "$PYTHONPATH"
  ];

  pyproject = true;
  pythonImportsCheck = [ "flet_cli" ];

  pythonRelaxDeps = [
    "qrcode"
    "watchdog"
  ];

  sourceRoot = "${src.name}/sdk/python/packages/flet-cli";

  meta = {
    description = "Command-line interface tool for Flet, a framework for building interactive multi-platform applications using Python";
    homepage = "https://flet.dev/";
    changelog = "https://github.com/flet-dev/flet/releases/tag/v${version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      heyimnova
    ];

    mainProgram = "flet";
  };
}
