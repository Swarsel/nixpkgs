{
  lib,
  fetchFromGitHub,
  dmenu,
  python3Packages,
  replaceVars,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "dmensamenu";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "dotlambda";
    repo = "dmensamenu";
    tag = finalAttrs.version;
    hash = "sha256-dtQpNDhw1HklEtltYl3yiz54UDLOJWJHNZEuQGaIYbI=";
  };

  patches = [
    (replaceVars ./dmenu-path.patch {
      inherit dmenu;
    })
  ];

  # No tests implemented
  doCheck = false;
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    requests
  ];

  pyproject = true;

  meta = {
    description = "Print German canteen menus using dmenu and OpenMensa";
    homepage = "https://github.com/dotlambda/dmensamenu";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "dmensamenu";
  };
})
