{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "i3-balance-workspace";
  version = "1.8.6";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-zJdn/Q6r60FQgfehtQfeDkmN0Rz3ZaqgNhiWvjyQFy0=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'poetry.masonry.api' 'poetry.core.masonry.api' \
      --replace-fail 'poetry>=' 'poetry-core>='
  '';

  doCheck = false; # project has no test

  build-system = [
    python3Packages.poetry-core
  ];

  dependencies = [
    python3Packages.i3ipc
  ];

  pyproject = true;
  pythonImportsCheck = [ "i3_balance_workspace" ];

  meta = {
    description = "Balance windows and workspaces in i3wm";
    homepage = "https://pypi.org/project/i3-balance-workspace/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ euxane ];
    mainProgram = "i3_balance_workspace";
  };
})
