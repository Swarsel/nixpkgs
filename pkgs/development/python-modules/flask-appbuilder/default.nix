{
  lib,
  apispec,
  buildPythonPackage,
  click,
  colorama,
  email-validator,
  fetchPypi,
  flask,
  flask-babel,
  flask-jwt-extended,
  flask-limiter,
  flask-login,
  flask-openid,
  flask-sqlalchemy,
  flask-wtf,
  jsonschema,
  marshmallow,
  marshmallow-sqlalchemy,
  prison,
  pyjwt,
  python-dateutil,
  pyyaml,
  sqlalchemy-utils,
}:

buildPythonPackage rec {
  pname = "flask-appbuilder";
  version = "5.0.2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-9Xe5gqGuQLwhMjjO25PDnGfPIZmqHgBuCH6hs1B9VFA=";
    pname = "Flask-AppBuilder";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "apispec[yaml]>=3.3, <6" "apispec[yaml]" \
      --replace "Flask-SQLAlchemy>=2.4, <3" "Flask-SQLAlchemy" \
      --replace "Flask-Babel>=1, <3" "Flask-Babel" \
      --replace "marshmallow-sqlalchemy>=0.22.0, <0.27.0" "marshmallow-sqlalchemy" \
      --replace "prison>=0.2.1, <1.0.0" "prison"
  '';

  propagatedBuildInputs = [
    apispec
    colorama
    click
    email-validator
    flask
    flask-babel
    flask-limiter
    flask-login
    flask-openid
    flask-sqlalchemy
    flask-wtf
    flask-jwt-extended
    jsonschema
    marshmallow
    marshmallow-sqlalchemy
    python-dateutil
    prison
    pyjwt
    pyyaml
    sqlalchemy-utils
  ]
  ++ apispec.optional-dependencies.yaml;

  # Majority of tests require network access or mongo
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "flask_appbuilder" ];

  meta = {
    description = "Application development framework, built on top of Flask";
    homepage = "https://github.com/dpgaspar/flask-appbuilder/";
    changelog = "https://github.com/dpgaspar/Flask-AppBuilder/blob/v${version}/CHANGELOG.rst";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    # Support for flask-sqlalchemy >= 3.0 is missing, https://github.com/dpgaspar/Flask-AppBuilder/pull/1940
    broken = true;
  };
}
