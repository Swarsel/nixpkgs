{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildHomeAssistantComponent,
  curl-cffi,
  homeassistant,
  icalendar,
  icalevents,
  jinja2,
  lxml,
  pdfminer-six,
  pycryptodome,
  pypdf,
  pytestCheckHook,
  pyyaml,
  requests,
}:

buildHomeAssistantComponent rec {
  version = "2.30.0";

  src = fetchFromGitHub {
    inherit owner;
    repo = "hacs_waste_collection_schedule";
    tag = "v${version}";
    hash = "sha256-9MQBKVm0IgVG0ePWe7Q1PskCa0p/6bNxj4IH73aLQnA=";
  };

  nativeCheckInputs = [
    homeassistant
    jinja2
    pytestCheckHook
    pyyaml
    requests
  ];

  dependencies = [
    beautifulsoup4
    curl-cffi
    icalendar
    icalevents
    lxml
    pdfminer-six
    pycryptodome
    pypdf
  ];

  domain = "waste_collection_schedule";
  owner = "mampfes";

  meta = {
    description = "Home Assistant integration framework for (garbage collection) schedules";
    homepage = "https://github.com/mampfes/hacs_waste_collection_schedule";
    changelog = "https://github.com/mampfes/hacs_waste_collection_schedule/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jamiemagee ];
  };
}
