{
  lib,
  fetchFromGitHub,
  expect,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "exe2hex";
  version = "1.5.2-unstable-2020-04-27";

  src = fetchFromGitHub {
    owner = "g0tmi1k";
    repo = "exe2hex";
    rev = "e563b353306a0f34d96150b8992f543931f907ea";
    hash = "sha256-wriB1k45QWNCIsSb30Z3IilTGZqnc+X1+qkRrxgDxzU=";
  };

  postPatch = ''
    substituteInPlace exe2hex.py \
      --replace-fail "/usr/bin/expect" "${lib.getExe expect}"
  '';

  propagatedBuildInputs = [
    expect
  ];

  postInstall = ''
    install -Dm 555 exe2hex.py $out/bin/exe2hex
  '';

  pyproject = false;

  meta = {
    description = "Inline file transfer using in-built Windows tools";
    homepage = "https://github.com/g0tmi1k/exe2hex";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "exe2hex";
  };
}
