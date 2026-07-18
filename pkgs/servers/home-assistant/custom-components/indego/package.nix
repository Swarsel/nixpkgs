{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  pyindego,
}:

buildHomeAssistantComponent rec {
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "sander1988";
    repo = "Indego";
    tag = version;
    hash = "sha256-pjkrodMFv8ZiSxmAK/JXuQbj6dfdkBf0FmhSMchTjsI=";
  };

  dependencies = [ pyindego ];
  domain = "indego";
  owner = "sander1988";

  meta = {
    description = "Bosch Indego lawn mower component";
    homepage = "https://github.com/sander1988/Indego";
    changelog = "https://github.com/sander1988/Indego/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
