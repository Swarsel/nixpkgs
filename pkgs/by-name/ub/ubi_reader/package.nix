{
  lib,
  fetchFromGitHub,
  gitUpdater,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "ubi_reader";
  version = "0.8.10";

  src = fetchFromGitHub {
    owner = "onekey-sec";
    repo = "ubi_reader";
    rev = "v${finalAttrs.version}";
    hash = "sha256-fXJiQZ1QWUmkRM+WI8DSIsay9s1w3hKloRuCcUNwZjM=";
  };

  # There are no tests in the source
  doCheck = false;
  build-system = [ python3.pkgs.poetry-core ];
  dependencies = [ python3.pkgs.lzallright ];
  pyproject = true;

  passthru = {
    updateScript = gitUpdater {
      ignoredVersions = "_[a-z]+$";
      rev-prefix = "v";
    };
  };

  meta = {
    description = "Python scripts capable of extracting and analyzing the contents of UBI and UBIFS images";
    homepage = "https://github.com/onekey-sec/ubi_reader";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ vlaci ];
  };
})
