{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "fierce";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "mschwager";
    repo = "fierce";
    tag = finalAttrs.version;
    sha256 = "sha256-y5ZSDJCTqslU78kXGyk6DajBpX7xz1CVmbhYerHmyis=";
  };

  # Tests require network access
  doCheck = false;
  build-system = with python3.pkgs; [ poetry-core ];
  dependencies = with python3.pkgs; [ dnspython ];
  pyproject = true;
  pythonImportsCheck = [ "fierce" ];
  pythonRelaxDeps = [ "dnspython" ];

  meta = {
    description = "DNS reconnaissance tool for locating non-contiguous IP space";
    homepage = "https://github.com/mschwager/fierce";
    changelog = "https://github.com/mschwager/fierce/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    mainProgram = "fierce";
  };
})
