{
  lib,
  buildNpmPackage,
  buildPythonPackage,
  fetchPypi,
  hatch-vcs,
  hatchling,
  jinja2,
  pytest,
  pytest-metadata,
}:
let
  pname = "pytest-html";
  version = "4.2.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-tqiMulB1ANhwmVkgHi51fTlB6Fn9F8/U7Yexb8DGeRI=";
    pname = "pytest_html";
  };

  web-assets = buildNpmPackage {
    inherit version src;
    pname = "${pname}-web-assets";
    npmDepsHash = "sha256-WJ0Ff0Y1u4EiIauEDGeOqLwY5Wk9wgjIvOGUmDog8rQ=";

    installPhase = ''
      runHook preInstall

      install -Dm644 src/pytest_html/resources/{app.js,style.css} -t $out/lib

      runHook postInstall
    '';
  };
in

buildPythonPackage {
  inherit pname version src;

  nativeBuildInputs = [
    hatch-vcs
    hatchling
  ];

  buildInputs = [
    pytest
    web-assets
  ];

  propagatedBuildInputs = [
    jinja2
    pytest-metadata
  ];

  env.HATCH_BUILD_NO_HOOKS = true;

  preBuild = ''
    install -Dm644 ${web-assets}/lib/{app.js,style.css} -t src/pytest_html/resources
  '';

  # tests require network access
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "pytest_html" ];

  meta = {
    description = "Plugin for generating HTML reports";
    homepage = "https://github.com/pytest-dev/pytest-html";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ mpoquet ];
  };
}
