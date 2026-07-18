{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "trustymail";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "cisagov";
    repo = "trustymail";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NF89Am/sG3Ruaws2SUofrbLoEiKdYpgPuXIAKjst9hk=";
  };

  nativeCheckInputs = with python3.pkgs; [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = with python3.pkgs; [ setuptools ];

  dependencies =
    with python3.pkgs;
    [
      dnspython
      docopt
      publicsuffixlist
      py3dns
      pyspf
      requests
    ]
    ++ publicsuffixlist.optional-dependencies.update;

  pyproject = true;
  pythonImportsCheck = [ "trustymail" ];

  meta = {
    description = "Tool to scan domains and return data based on trustworthy email best practices";
    homepage = "https://github.com/cisagov/trustymail";
    changelog = "https://github.com/cisagov/trustymail/releases/tag/${finalAttrs.src.tag}";
    license = with lib.licenses; [ cc0 ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "trustymail";
  };
})
