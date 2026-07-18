{
  lib,
  fetchFromGitLab,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "ringo";
  version = "1.1.0";

  src = fetchFromGitLab {
    owner = "nomadic-labs";
    repo = "ringo";
    rev = "v${finalAttrs.version}";
    hash = "sha256-8dThhY7TIjd0lLdCt6kxr0yhgVGDyN6ZMSx0Skfbcwk=";
  };

  doCheck = true;
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Caches (bounded-size key-value stores) and other bounded-size stores";
    homepage = "https://gitlab.com/nomadic-labs/ringo";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.ulrikstrid ];
  };
})
