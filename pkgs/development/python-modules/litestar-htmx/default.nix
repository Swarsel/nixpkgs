{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "litestar-htmx";
  version = "0.5.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-4C0aOpIXLIdINfo+Z0nWWun8Ym0N9GcZSQoWKT4hRvs=";
    pname = "litestar_htmx";
  };

  build-system = [
    hatchling
  ];

  pyproject = true;

  meta = {
    description = "HTMX Integration for Litesstar";
    homepage = "https://docs.litestar.dev/latest/usage/htmx.html";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = lib.platforms.unix;
  };
}
