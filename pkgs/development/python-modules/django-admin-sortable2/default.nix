{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  buildPythonPackage,
  django,
  setuptools,
}:
let
  pname = "django-admin-sortable2";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "jrief";
    repo = "django-admin-sortable2";
    tag = version;
    hash = "sha256-noY0SELM+ZBWDoZ/pl1oUV/S0VICtG7sSaCtPGjjOpQ=";
  };

  assets = buildNpmPackage {
    inherit version src;
    pname = "${pname}-assets";
    npmDepsHash = "sha256-zM2iSCrGX5sS7Ysmmo8nR+/V9pMOatN6DX/G+hGdFEU=";

    installPhase = ''
      runHook preInstall

      install -Dm644 adminsortable2/static/adminsortable2/js/*.js -t $out

      runHook postInstall
    '';
  };
in

buildPythonPackage rec {
  inherit pname version src;

  preBuild = ''
    install -Dm644 ${assets}/*.js -t adminsortable2/static/adminsortable2/js
  '';

  # Tests are very slow (end-to-end with playwright)
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ django ];
  pyproject = true;
  pythonImportsCheck = [ "adminsortable2" ];

  meta = {
    description = "Generic drag-and-drop ordering for objects in the Django admin interface";
    homepage = "https://github.com/jrief/django-admin-sortable2";
    changelog = "https://github.com/jrief/django-admin-sortable2/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sephi ];
  };
}
