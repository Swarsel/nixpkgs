{
  buildDunePackage,
  dream,
  ppxlib,
  pure-html,
}:

buildDunePackage {
  inherit (pure-html) src version meta;
  pname = "dream-html";

  buildInputs = [
    ppxlib
  ];

  propagatedBuildInputs = [
    pure-html
    dream
  ];

  minimalOCamlVersion = "5.3";
}
