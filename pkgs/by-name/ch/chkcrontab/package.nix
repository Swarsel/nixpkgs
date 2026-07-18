{
  lib,
  fetchPypi,
  python3,
}:

with python3.pkgs;

buildPythonApplication (finalAttrs: {
  pname = "chkcrontab";
  version = "1.7";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    sha256 = "0gmxavjkjkvjysgf9cf5fcpk589gb75n1mn20iki82wifi1pk1jn";
  };

  format = "setuptools";

  meta = {
    description = "Tool to detect crontab errors";
    homepage = "https://github.com/lyda/chkcrontab";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "chkcrontab";
  };
})
