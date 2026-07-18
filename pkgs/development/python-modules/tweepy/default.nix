{
  lib,
  fetchFromGitHub,
  aiohttp,
  async-lru,
  buildPythonPackage,
  flit-core,
  oauthlib,
  pytestCheckHook,
  requests,
  requests-oauthlib,
  vcrpy,
}:

buildPythonPackage rec {
  pname = "tweepy";
  version = "4.17.0";

  src = fetchFromGitHub {
    owner = "tweepy";
    repo = "tweepy";
    tag = "v${version}";
    hash = "sha256-Jr/62vXxBIiZGQeM5bbqnHDP9GCxrbJmCF2oiYglLbE=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    vcrpy
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ flit-core ];

  dependencies = [
    oauthlib
    requests
    requests-oauthlib
  ];

  # The checks with streaming fail due to (seemingly) not decoding (or unexpectedly sending response in) GZIP
  # Same issue impacted mastodon-py, see https://github.com/halcy/Mastodon.py/commit/cd86887d88bbc07de462d1e00a8fbc3d956c0151 (who just disabled these)
  disabledTestPaths = [ "tests/test_client.py" ];

  disabledTests = [
    "test_indicate_direct_message_typing"
    "testcachedifferentqueryparameters"
    "testcachedresult"
    "testcreatedestroyblock"
    "testcreatedestroyfriendship"
    "testcreateupdatedestroylist"
    "testgetfollowerids"
    "testgetfollowers"
    "testgetfriendids"
    "testgetfriends"
    "testgetuser"
    "testcursorcursoritems"
    "testcursorcursorpages"
    "testcursornext"
  ];

  optional-dependencies = {
    async = [
      aiohttp
      async-lru
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "tweepy" ];

  meta = {
    description = "Twitter library for Python";
    homepage = "https://github.com/tweepy/tweepy";
    changelog = "https://github.com/tweepy/tweepy/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ marius851000 ];
  };
}
