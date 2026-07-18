{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  libiconv,
  pytestCheckHook,
  rustPlatform,
}:

# r-ryantm wants to downgrade
# nixpkgs-update: no auto update
buildPythonPackage rec {
  pname = "biliass";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "yutto-dev";
    repo = "yutto";
    tag = "biliass@${version}";
    hash = "sha256-ZB18BQJRSwA/ERHjqmp+D39UqTvdYpbhwLjaizM5R2I=";
  };

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ];

  doCheck = false; # test artifacts missing
  nativeCheckInputs = [ pytestCheckHook ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit
      pname
      version
      src
      sourceRoot
      cargoRoot
      ;

    hash = "sha256-gOYgYi8RlWBe0astv6D6/J7Ge20TM/19zJHwoCevpIo=";
  };

  cargoRoot = "rust";
  pyproject = true;
  pythonImportsCheck = [ "biliass" ];
  sourceRoot = "${src.name}/packages/biliass";

  meta = {
    description = "Convert Bilibili XML/protobuf danmaku to ASS subtitle";
    homepage = "https://github.com/yutto-dev/biliass";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ linsui ];
    mainProgram = "biliass";
  };
}
