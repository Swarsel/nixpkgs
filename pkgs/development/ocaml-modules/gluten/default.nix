{
  lib,
  fetchurl,
  bigstringaf,
  buildDunePackage,
  faraday,
}:

buildDunePackage (finalAttrs: {
  pname = "gluten";
  version = "0.5.2";

  src = fetchurl {
    url = "https://github.com/anmonteiro/gluten/releases/download/${finalAttrs.version}/gluten-${finalAttrs.version}.tbz";
    hash = "sha256-se7Yn59ggLtL0onMjSUsa88B8D05Vybmb6YGcgfnAV8=";
  };

  propagatedBuildInputs = [
    bigstringaf
    faraday
  ];

  doCheck = false; # No tests
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Implementation of a platform specific runtime code for driving network libraries based on state machines, such as http/af, h2 and websocketaf";
    homepage = "https://github.com/anmonteiro/gluten";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
})
