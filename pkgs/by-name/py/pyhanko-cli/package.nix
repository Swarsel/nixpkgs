{
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3Packages,
  versionCheckHook,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "pyhanko-cli";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "MatthiasValvekens";
    repo = "pyhanko";
    tag = "pyhanko-cli/v${finalAttrs.version}";
    hash = "sha256-huOy04wY7xP1gZ5azsZYnMXLZ4MwMkLGujlgXTtjLy4=";
  };

  postPatch = ''
    substituteInPlace src/pyhanko/cli/version.py \
      --replace-fail "0.0.0.dev1" "${finalAttrs.version}" \
      --replace-fail "(0, 0, 0, 'dev1')" "tuple(\"${finalAttrs.version}\".split(\".\"))"
  '';

  nativeBuildInputs = [
    python3Packages.pyprojectVersionPatchHook
  ];

  nativeCheckInputs = [
    versionCheckHook
  ]
  ++ (with python3Packages; [
    pytestCheckHook
    pytest-asyncio
    pyhanko.testData
    requests-mock
    freezegun
    certomancer
    aiohttp
  ]);

  build-system = [ python3Packages.setuptools ];

  dependencies =
    with python3Packages;
    [
      asn1crypto
      tzlocal
      pyhanko
      pyhanko-certvalidator
      click
      platformdirs
    ]
    ++ lib.concatAttrValues pyhanko.optional-dependencies;

  disabledTestPaths = [
    # ImportError: cannot import name 'SOFTHSM' from 'test_utils.signing_commons'
    "tests/test_cli_signing_pkcs11.py"
  ];

  pyproject = true;
  sourceRoot = "${finalAttrs.src.name}/pkgs/pyhanko-cli";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex=pyhanko-cli/v(.*)"
    ];
  };

  meta = {
    description = "Sign and stamp PDF files";
    homepage = "https://github.com/MatthiasValvekens/pyHanko/tree/master/pkgs/pyhanko-cli";
    changelog = "https://github.com/MatthiasValvekens/pyHanko/blob/${finalAttrs.src.tag}/docs/changelog.rst#pyhanko-cli";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.antonmosich ];
    mainProgram = "pyhanko";
  };
})
