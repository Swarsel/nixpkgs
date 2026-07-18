{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  isPy3k,
  pytestCheckHook,
  setuptools,
  stups-cli-support,
  stups-tokens,
}:

buildPythonPackage rec {
  pname = "stups-zign";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "zalando-stups";
    repo = "zign";
    rev = version;
    sha256 = "1vk6pnprnd5lfx96hc2c1n7kwh99f260r730x4y2h7lamlv82fh4";
  };

  patches = [
    # pytest 5 is currently unsupported. Fetch and apply a pr that resolves this.
    (fetchpatch {
      sha256 = "1zmyvg1z1asaqqsmxvsx0srvxd6gkgavppvg3dblxwhkml01awqk";
      url = "https://github.com/zalando-stups/zign/commit/50140720211e547b0e59f7ddb39a732f0cc73ad7.patch";
    })
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = "
    export HOME=$TEMPDIR
  ";

  build-system = [ setuptools ];

  dependencies = [
    stups-tokens
    stups-cli-support
  ];

  disabled = !isPy3k;
  pyproject = true;

  meta = {
    description = "OAuth2 token management command line utility";
    homepage = "https://github.com/zalando-stups/zign";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.mschuwalow ];
  };
}
