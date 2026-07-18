{
  lib,
  buildPythonPackage,
  fetchPypi,
  gobject-introspection,
  goocanvas_2,
  gtk3,
  pkg-config,
  pygobject3,
}:

buildPythonPackage rec {
  pname = "goocalendar";
  version = "0.8.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-LwL5TLRkD6ALucabLUeB0k4rIX+O/aW2ebS2rZPjIUs=";
    pname = "GooCalendar";
  };

  nativeBuildInputs = [
    pkg-config
    gobject-introspection
  ];

  buildInputs = [
    gtk3
    goocanvas_2
  ];

  propagatedBuildInputs = [ pygobject3 ];
  # No upstream tests available
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "goocalendar" ];

  meta = {
    description = "Calendar widget for GTK using PyGoocanvas";
    homepage = "https://goocalendar.tryton.org/";
    changelog = "https://foss.heptapod.net/tryton/goocalendar/-/blob/${version}/CHANGELOG";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ udono ];
  };
}
