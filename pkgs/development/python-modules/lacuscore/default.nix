{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  defang,
  dnspython,
  orjson,
  playwrightcapture,
  poetry-core,
  pydantic,
  redis,
  requests,
  ua-parser,
}:

buildPythonPackage (finalAttrs: {
  pname = "lacuscore";
  version = "1.25.1";

  src = fetchFromGitHub {
    owner = "ail-project";
    repo = "LacusCore";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wbs/EZuK6eK8mKOB7sb0l4Y/orhugmoEnwy1bclusoU=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    defang
    dnspython
    orjson
    playwrightcapture
    pydantic
    redis
    requests
    ua-parser
  ]
  ++ playwrightcapture.optional-dependencies.recaptcha
  ++ redis.optional-dependencies.hiredis
  ++ ua-parser.optional-dependencies.regex;

  pyproject = true;
  pythonImportsCheck = [ "lacuscore" ];

  pythonRelaxDeps = [
    "dnspython"
    "orjson"
    "pydantic"
    "redis"
    "requests"
  ];

  meta = {
    description = "Modulable part of Lacus";
    homepage = "https://github.com/ail-project/LacusCore";
    changelog = "https://github.com/ail-project/LacusCore/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
  };
})
