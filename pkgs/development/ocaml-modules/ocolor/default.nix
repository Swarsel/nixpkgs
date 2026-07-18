{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  cppo,
}:

buildDunePackage (finalAttrs: {
  pname = "ocolor";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "marc-chevalier";
    repo = "ocolor";
    tag = finalAttrs.version;
    sha256 = "osQTZGJp9yDoKNa6WoyhViNbRg1ukcD0Jxiu4VxqeUc=";
  };

  nativeBuildInputs = [
    cppo
  ];

  minimalOCamlVersion = "4.02";

  meta = {
    description = "Print with style in your terminal using Format’s semantic tags";
    homepage = "https://github.com/marc-chevalier/ocolor";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ toastal ];
  };
})
