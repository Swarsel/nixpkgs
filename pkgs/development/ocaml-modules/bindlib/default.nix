{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  earley,
  timed,
}:

buildDunePackage (finalAttrs: {
  pname = "bindlib";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "rlepigre";
    repo = "ocaml-bindlib";
    rev = finalAttrs.version;
    hash = "sha256-058yMbz9ExvgNG/kY9tPk70XSeVRSSKVg4n4F4fmPu4=";
  };

  doCheck = true;

  checkInputs = [
    earley
    timed
  ];

  minimalOCamlVersion = "4.07";

  meta = {
    description = "Efficient binder representation in Ocaml";
    homepage = "https://rlepigre.github.io/ocaml-bindlib";
    changelog = "https://github.com/rlepigre/ocaml-bindlib/raw/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
})
