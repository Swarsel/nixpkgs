{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  jq,
  python3,
}:

let
  python = python3.override {
    packageOverrides = self: super: {
      # pyca is incompatible with SQLAlchemy 2.0
      sqlalchemy = super.sqlalchemy_1_4;
    };

    self = python;
  };

  frontend = buildNpmPackage rec {
    pname = "pyca";
    version = "4.5";

    src = fetchFromGitHub {
      owner = "opencast";
      repo = "pyCA";
      rev = "v${version}";
      sha256 = "sha256-cTkWkOmgxJZlddqaSYKva2wih4Mvsdrd7LD4NggxKQk=";
    };

    postPatch = ''
      ${jq}/bin/jq '. += {"version": "${version}"}' < package.json > package.json.tmp
      mv package.json.tmp package.json
    '';

    nativeBuildInputs = [
      jq
      python
    ];

    npmDepsHash = "sha256-0U+semrNWTkNu3uQQkiJKZT1hB0/IfkL84G7/oP8XYY=";

    installPhase = ''
      mkdir -p $out/static
      cp -R pyca/ui/static/* $out/static/
    '';
  };

in
python3.pkgs.buildPythonApplication rec {
  pname = "pyca";
  version = "4.5";

  src = fetchFromGitHub {
    owner = "opencast";
    repo = "pyCA";
    rev = "v${version}";
    sha256 = "sha256-cTkWkOmgxJZlddqaSYKva2wih4Mvsdrd7LD4NggxKQk=";
  };

  postPatch = ''
    sed -i -e 's#static_folder=.*#static_folder="${frontend}/static")#' pyca/ui/__init__.py
  '';

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python.pkgs; [
    pycurl
    python-dateutil
    configobj
    sqlalchemy
    sdnotify
    psutil
    flask
    prometheus-client
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyca" ];

  passthru = {
    inherit frontend;
  };

  meta = {
    description = "Fully functional Opencast capture agent written in Python";
    homepage = "https://github.com/opencast/pyCA";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ pmiddend ];
    mainProgram = "pyca";
    broken = stdenv.hostPlatform.isDarwin;
  };
}
