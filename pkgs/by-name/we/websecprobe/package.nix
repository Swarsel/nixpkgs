{
  lib,
  fetchPypi,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "websecprobe";
  version = "0.0.12";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-RX4tc6JaUVaNx8nidn8eMcbsmbcSY+VZbup6c6P7oOs=";
    pname = "WebSecProbe";
  };

  postInstall = ''
    mv $out/bin/WebSecProbe $out/bin/$pname
  '';

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    requests
    tabulate
  ];

  pyproject = true;
  pythonImportsCheck = [ "WebSecProbe" ];

  meta = {
    description = "Web Security Assessment Tool";
    homepage = "https://github.com/spyboy-productions/WebSecProbe/";
    changelog = "https://github.com/spyboy-productions/WebSecProbe/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    platforms = lib.platforms.linux;
    mainProgram = "websecprobe";
  };
})
