{
  lib,
  buildHomeAssistantComponent,
  fetchFromCodeberg,
  gpiod,
}:

buildHomeAssistantComponent rec {
  version = "0.0.4";

  src = fetchFromCodeberg {
    owner = "raboof";
    repo = "ha-gpio";
    rev = "v${version}";
    hash = "sha256-JyyJPI0lbZLJj+016WgS1KXU5rnxUmRMafel4/wKsYk=";
  };

  dependencies = [ gpiod ];
  domain = "gpio";
  owner = "raboof";

  meta = {
    description = "Home Assistant GPIO custom integration";
    homepage = "https://codeberg.org/raboof/ha-gpio";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ raboof ];
  };
}
