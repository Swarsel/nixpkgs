{
  lib,
  fetchFromGitHub,
  # nativeBuildInputs
  beets-minimal,
  buildPythonPackage,
  fetchpatch,
  # build-system
  hatchling,
  mock,
  pillow,
  pytest-cov-stub,
  # tests
  pytestCheckHook,
  tomli,
  typeguard,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "beets-alternatives";
  version = "0.14.1";

  src = fetchFromGitHub {
    owner = "geigerzaehler";
    repo = "beets-alternatives";
    tag = "v${version}";
    hash = "sha256-C4EVJwzLhwQJz/iUKrIKUjhYHIpPrETqyQi0DByZM3Y=";
  };

  patches = [
    # Fixes failing tests; see https://github.com/geigerzaehler/beets-alternatives/pull/221
    (fetchpatch {
      hash = "sha256-rURvP7aNJ+I9bPjk43t8rYujOK1iUS1J4RFMAHfa5AU=";
      url = "https://github.com/geigerzaehler/beets-alternatives/commit/84fdb0fa15225cce1e881b07bddcb52715677915.patch";
    })
    # Fix for Beets 2.12; see https://github.com/geigerzaehler/beets-alternatives/pull/234
    (fetchpatch {
      hash = "sha256-47HhaYWzHQakGlbUWdfG5qkfvbadbow1i+O74JnKPwM=";
      url = "https://github.com/geigerzaehler/beets-alternatives/commit/e27772bb627d1b0763685d7add209d40987f2b95.patch";
    })
  ];

  nativeBuildInputs = [
    beets-minimal
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    mock
    pillow
    tomli
    typeguard
    writableTmpDirAsHomeHook
  ];

  build-system = [
    hatchling
  ];

  pyproject = true;

  meta = {
    description = "Beets plugin to manage external files";
    homepage = "https://github.com/geigerzaehler/beets-alternatives";
    changelog = "https://github.com/geigerzaehler/beets-alternatives/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      aszlig
      lovesegfault
    ];
  };
}
