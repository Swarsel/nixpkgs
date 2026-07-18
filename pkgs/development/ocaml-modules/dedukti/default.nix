{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  cmdliner,
  menhir,
}:

buildDunePackage (finalAttrs: {
  pname = "dedukti";
  version = "2.7";

  src = fetchFromGitHub {
    owner = "Deducteam";
    repo = "dedukti";
    rev = "v${finalAttrs.version}";
    hash = "sha256-SFxbgq2znO+OCEFzuekVquvtOEuCQanseKy+iZAeWbc=";
  };

  nativeBuildInputs = [ menhir ];
  buildInputs = [ cmdliner ];
  doCheck = false; # requires `tezt`
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Logical framework based on the λΠ-calculus modulo rewriting";
    homepage = "https://deducteam.github.io";
    changelog = "https://github.com/Deducteam/Dedukti/raw/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.cecill-b;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
})
