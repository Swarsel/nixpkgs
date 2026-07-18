{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage (finalAttrs: {
  pname = "fontawesomefree";
  version = "6.6.0";

  # they only provide a wheel
  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-WZtXRDHJvZLtX8BU0QRaB8QjNdo2wXiE8rk0dV7vkIk=";
    dist = "py3";
    format = "wheel";
    python = "py3";
  };

  format = "wheel";
  pythonImportsCheck = [ "fontawesomefree" ];

  meta = {
    description = "Icon library and toolkit";
    homepage = "https://github.com/FortAwesome/Font-Awesome";

    license = with lib.licenses; [
      ofl
      cc-by-40
    ];

    maintainers = with lib.maintainers; [ netali ];
  };
})
