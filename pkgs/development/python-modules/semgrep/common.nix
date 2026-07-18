{ lib }:

rec {
  version = "1.164.0";

  # fetch pre-built semgrep-core since the ocaml build is complex and relies on
  # the opam package manager at some point
  # pulling it out of the python wheel as r2c no longer release a built binary
  # on github releases
  core = {
    aarch64-darwin = {
      hash = "sha256-AsKxA5Wmy3NEQJ0kS6ylE33d0W86e9F494aiIkwyrcA=";
      platform = "macosx_11_0_arm64";
    };

    aarch64-linux = {
      hash = "sha256-N24E9xOyRO7pXopRs+gSQM2nwHE214GfcntcoH7H7Kk=";
      platform = "manylinux_2_34_aarch64";
    };

    x86_64-linux = {
      hash = "sha256-dFrlzhvvfJsDyStDHRdMpu54AaXioEfGSsIQTH5pUvs=";
      platform = "manylinux_2_34_x86_64";
    };
  };

  # This tag is used to select the correct wheel from PyPI.
  # It is updated by the update.sh script.
  pythonWheelTag = "cp310.cp311.cp312.cp313.cp314.py310.py311.py312.py313.py314";
  srcHash = "sha256-ced287/jH+as/1rGBOfoZ06UuQ1sf1YI4AMHbHrtnHU=";

  # submodule dependencies
  # these are fetched so we:
  #   1. don't fetch the many submodules we don't need
  #   2. avoid fetchSubmodules since it's prone to impurities
  submodules = {
    "cli/src/semgrep/semgrep_interfaces" = {
      hash = "sha256-dy+oOB0QmZjMpTYINSPIjzhpN6d/45DaajqumKIYxC4=";
      owner = "semgrep";
      repo = "semgrep-interfaces";
      rev = "f4a74a03e8ec3dd368b96101648a3210e03fa61e";
    };
  };

  meta = {
    description = "Lightweight static analysis for many languages";

    longDescription = ''
      Semgrep is a fast, open-source, static analysis tool for finding bugs and
      enforcing code standards at editor, commit, and CI time. Semgrep analyzes
      code locally on your computer or in your build environment: code is never
      uploaded. Its rules look like the code you already write; no abstract
      syntax trees, regex wrestling, or painful DSLs.
    '';

    homepage = "https://semgrep.dev/";
    changelog = "https://github.com/semgrep/semgrep/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.lgpl21Plus;

    maintainers = with lib.maintainers; [
      jk
      ambroisie
      caverav
    ];

    downloadPage = "https://github.com/semgrep/semgrep/";
  };
}
