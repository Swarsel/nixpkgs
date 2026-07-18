{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "uwsgi-chunked";
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "btimby";
    repo = "uwsgi-chunked";
    tag = version;
    hash = "sha256-5TNCnQhnT1gAblgs+AAW62HoNDPM54hpxgCnYl07j3I=";
  };

  # requires running containers via docker
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "uwsgi_chunked" ];

  meta = {
    description = "WSGI application wrapper that handles Transfer-Encoding: chunked";
    homepage = "https://github.com/btimby/uwsgi-chunked";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ defelo ];
  };
}
