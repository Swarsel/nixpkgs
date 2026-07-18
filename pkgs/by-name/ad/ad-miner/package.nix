{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "ad-miner";
  version = "1.8.1";

  src = fetchFromGitHub {
    owner = "AD-Security";
    repo = "AD_Miner";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iI7jiENPYCIVJnIG/M4ft4dkR2Ja21gzR+ISeyZvUEo=";
  };

  # Project has no tests
  doCheck = false;
  build-system = with python3.pkgs; [ poetry-core ];

  dependencies = with python3.pkgs; [
    neo4j
    numpy
    pytz
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "ad_miner" ];
  # All requirements are pinned
  pythonRelaxDeps = true;

  meta = {
    description = "Active Directory audit tool that leverages cypher queries to crunch data from Bloodhound";
    homepage = "https://github.com/AD-Security/AD_Miner";
    changelog = "https://github.com/AD-Security/AD_Miner/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "AD-miner";
  };
})
