{
  lib,
  buildPythonPackage,
  fetchPypi,
  postgresql,
  unittestCheckHook,
  uv-build,
}:

buildPythonPackage (finalAttrs: {
  pname = "pgsanity";
  version = "0.3.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-Po/DPQpk54w1gWOL9aArN6I8dmMb7uRYxuRMI6MIDKU=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.8.19,<0.9.0" uv_build
  '';

  # To find "ecpg"
  nativeBuildInputs = [ (lib.getDev postgresql) ];
  propagatedBuildInputs = [ postgresql ];

  nativeCheckInputs = [
    unittestCheckHook
  ];

  build-system = [
    uv-build
  ];

  pyproject = true;
  unittestFlagsArray = [ "test" ];

  meta = {
    description = "Checks the syntax of Postgresql SQL files";

    longDescription = ''
      PgSanity checks the syntax of Postgresql SQL files by
      taking a file that has a list of bare SQL in it,
      making that file look like a C file with embedded SQL,
      run it through ecpg and
      let ecpg report on the syntax errors of the SQL.
    '';

    homepage = "https://github.com/markdrago/pgsanity";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nalbyuites ];
    mainProgram = "pgsanity";
  };
})
