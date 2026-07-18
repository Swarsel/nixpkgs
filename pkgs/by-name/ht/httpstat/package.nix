{
  lib,
  fetchFromGitHub,
  curl,
  glibcLocales,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "httpstat";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "reorx";
    repo = "httpstat";
    rev = finalAttrs.version;
    sha256 = "sha256-dOHFLw8suvpuZkcKEzq5HktMYBGE7+vtTD609TkAFfw=";
  };

  buildInputs = [ glibcLocales ];
  env.LC_ALL = "en_US.UTF-8";
  doCheck = false; # No tests
  build-system = with python3Packages; [ setuptools ];
  pyproject = true;
  runtimeDeps = [ curl ];

  meta = {
    description = "Curl statistics made simple";
    homepage = "https://github.com/reorx/httpstat";
    license = lib.licenses.mit;
    mainProgram = "httpstat";
  };
})
