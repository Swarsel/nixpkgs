{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  markdownify,
  numpy,
  pandas,
  poetry-core,
  pydantic,
  regex,
  requests,
  tls-client,
}:

buildPythonPackage rec {
  pname = "jobspy";
  version = "1.1.82";

  src = fetchFromGitHub {
    owner = "Bunsly";
    repo = "JobSpy";
    tag = version;
    hash = "sha256-iLtUIM7QBIl6UAcb1RvKt2uw5gHEIQXuo4z/OQu86wM=";
  };

  build-system = [ poetry-core ];

  dependencies = [
    numpy
    pandas
    pydantic
    regex
    requests
    markdownify
    tls-client
    beautifulsoup4
  ];

  pyproject = true;
  pythonImportsCheck = [ "jobspy" ];

  pythonRelaxDeps = [
    "numpy"
    "markdownify"
    "regex"
  ];

  # no package tests because they all require networking/polling
  meta = {
    description = "Jobs scraper library for job sites";
    homepage = "https://github.com/Bunsly/JobSpy";
    changelog = "https://github.com/Bunsly/JobSpy/releases/tag/${src.tag}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ ethancedwards8 ];
    downloadPage = "https://github.com/Bunsly/JobSpy";
  };
}
