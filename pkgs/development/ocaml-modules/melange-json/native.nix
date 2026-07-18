{
  buildDunePackage,
  melange-json,
  ppxlib,
  yojson,
}:

buildDunePackage {
  inherit (melange-json) version src;
  pname = "melange-json-native";

  propagatedBuildInputs = [
    ppxlib
    yojson
  ];

  doCheck = false; # Fails due to missing "melange-jest", which in turn fails in command "npx jest"
  minimalOCamlVersion = "4.12";

  meta = melange-json.meta // {
    description = "Compositional JSON encode/decode PPX for OCaml";
  };
}
