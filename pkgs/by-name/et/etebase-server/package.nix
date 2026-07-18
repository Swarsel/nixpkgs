{
  lib,
  fetchFromGitHub,
  nix-update-script,
  nixosTests,
  python3,
  withLdap ? false,
  withPostgres ? true,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "etebase-server";
  version = "0.14.2";

  src = fetchFromGitHub {
    owner = "etesync";
    repo = "server";
    tag = "v${finalAttrs.version}";
    hash = "sha256-W2u/d8X8luOzgy1CLNgujnwaoO1pR1QO1Ma7i4CGkdU=";
  };

  patches = [ ./secret.patch ];

  propagatedBuildInputs =
    with python3.pkgs;
    [
      aiofiles
      django
      fastapi
      msgpack
      pynacl
      redis
      uvicorn
      websockets
      watchfiles
      uvloop
      pyyaml
      python-dotenv
      httptools
      typing-extensions
    ]
    ++ lib.optional withLdap python-ldap
    ++ lib.optional withPostgres psycopg2;

  doCheck = false;

  postInstall = ''
    mkdir -p $out/bin $out/lib
    cp manage.py $out/bin/etebase-server
    wrapProgram $out/bin/etebase-server --prefix PYTHONPATH : "$PYTHONPATH"
    chmod +x $out/bin/etebase-server
  '';

  format = "setuptools";
  passthru.python = python3;
  # PYTHONPATH of all dependencies used by the package
  passthru.pythonPath = python3.pkgs.makePythonPath finalAttrs.propagatedBuildInputs;

  passthru.tests = {
    nixosTest = nixosTests.etebase-server;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Etebase (EteSync 2.0) server so you can run your own";
    homepage = "https://github.com/etesync/server";
    changelog = "https://github.com/etesync/server/blob/v${finalAttrs.version}/ChangeLog.md";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      felschr
      phaer
    ];

    mainProgram = "etebase-server";
  };
})
