{
  lib,
  fetchFromGitHub,
  fetchpatch,
  python3,
}:
python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "conkeyscan";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "CompassSecurity";
    repo = "conkeyscan";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xYCms+Su7FmaG7KVHZpzfD/wx9Gepz11t8dEK/YDfvI=";
  };

  patches = [
    # https://github.com/CompassSecurity/conkeyscan/pull/3
    (fetchpatch {
      hash = "sha256-zfHU/KsgzQvn/kNsWZy1hGZaBHw/he1zDTUHHV/BHFc=";
      name = "replace-random-user-agent-with-fake-useragent.patch";
      url = "https://github.com/nagapraneethk/conkeyscan/commit/f6cf61cc42fcc07930a06891b6c4a2653bfbf47f.patch";
    })
  ];

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "{{VERSION_PLACEHOLDER}}" "${finalAttrs.version}"
  '';

  # Project has no tests
  doCheck = false;
  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    atlassian-python-api
    beautifulsoup4
    clize
    loguru
    pysocks
    fake-useragent
    readchar
    requests-ratelimiter
  ];

  pyproject = true;
  pythonImportsCheck = [ "conkeyscan" ];

  meta = {
    description = "Tool to scan Confluence for keywords";
    homepage = "https://github.com/CompassSecurity/conkeyscan";
    changelog = "https://github.com/CompassSecurity/conkeyscan/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "conkeyscan";
  };
})
