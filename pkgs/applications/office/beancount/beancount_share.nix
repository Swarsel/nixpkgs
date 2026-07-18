{
  lib,
  fetchFromGitHub,
  beancount,
  beancount-plugin-utils,
  python3,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "beancount_share";
  version = "0.1.11";

  src = fetchFromGitHub {
    owner = "akuukis";
    repo = "beancount_share";
    rev = "v${version}";
    sha256 = "sha256-BW2KEC0pmervT71FBixPcQciEuGcElCd2wW7BZL1xUg=";
  };

  buildInputs = [
    python3.pkgs.setuptools
  ];

  propagatedBuildInputs = [
    beancount
    beancount-plugin-utils
  ];

  pyproject = true;

  meta = {
    description = "Beancount plugin to share expenses with external partners within one ledger";
    homepage = "https://github.com/akuukis/beancount_share";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ matthiasbeyer ];
  };
}
