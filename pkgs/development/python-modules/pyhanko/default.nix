{
  lib,
  stdenv,
  fetchFromGitHub,
  aiohttp,
  # dependencies
  asn1crypto,
  buildPythonPackage,
  # tests
  certomancer,
  cryptography,
  # optional-dependencies
  fonttools,
  freezegun,
  lxml,
  pillow,
  pyhanko-certvalidator,
  pyprojectVersionPatchHook,
  pytest-aiohttp,
  pytestCheckHook,
  python-barcode,
  python-pae,
  python-pkcs11,
  pyyaml,
  qrcode,
  requests,
  requests-mock,
  # build-system
  setuptools,
  signxml,
  tzlocal,
  uharfbuzz,
  xsdata,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyhanko";
  version = "0.35.2";

  src = fetchFromGitHub {
    owner = "MatthiasValvekens";
    repo = "pyHanko";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CY+YgUu8za5c0t2OKStKvCN9X8hVXT2sN42KSDiyMX8=";
  };

  postPatch = ''
    substituteInPlace src/pyhanko/version/__init__.py \
      --replace-fail "0.0.0.dev1" "${finalAttrs.version}" \
      --replace-fail "(0, 0, 0, 'dev1')" "tuple(\"${finalAttrs.version}\".split(\".\"))"
  '';

  nativeBuildInputs = [
    pyprojectVersionPatchHook
  ];

  nativeCheckInputs = [
    aiohttp
    certomancer
    freezegun
    pytest-aiohttp
    pytestCheckHook
    python-pae
    requests-mock
    finalAttrs.passthru.testData
    signxml
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    asn1crypto
    cryptography
    lxml
    pyhanko-certvalidator
    pyyaml
    requests
    tzlocal
  ];

  disabledTestPaths = [
    # ModuleNotFoundError: No module named 'csc_dummy'
    "tests/test_csc.py"
  ];

  disabledTests = [
    # Most of the test require working with local certificates,
    # contacting OSCP or performing requests
    "test_generic_data_sign_legacy"
    "test_generic_data_sign"
    "test_cms_v3_sign"
    "test_detached_cms_with_self_reported_timestamp"
    "test_detached_cms_with_tst"
    "test_detached_cms_with_content_tst"
    "test_detached_cms_with_wrong_content_tst"
    "test_detached_with_malformed_content_tst"
    "test_noop_attribute_prov"
    "test_detached_cades_cms_with_tst"
    "test_read_qr_config"
    "test_no_changes_policy"
    "test_bogus_metadata_manipulation"
    "test_tamper_sig_obj"
    "test_signed_file_diff_proxied_objs"
    "test_pades_revinfo_live"
    "test_diff_fallback_ok"
    "test_no_diff_summary"
    "test_ocsp_embed"
    "test_ts_fetch_aiohttp"
    "test_ts_fetch_requests"
  ];

  optional-dependencies = {
    async-http = [ aiohttp ];

    etsi = [
      xsdata
      signxml
    ];

    image-support = [
      pillow
      python-barcode
    ];

    opentype = [
      fonttools
      uharfbuzz
    ];

    pkcs11 = [ python-pkcs11 ];
    qr = [ qrcode ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pyhanko" ];
  sourceRoot = "${finalAttrs.src.name}/pkgs/pyhanko";

  passthru = {
    testData = buildPythonPackage {
      inherit (finalAttrs) version src;
      pname = "common-test-utils";

      # Include the test pdf/xml files etc. in the build output
      postPatch = ''
        echo "graft src/pyhanko_testing_commons/test_data" > MANIFEST.in
      '';

      build-system = [ setuptools ];

      dependencies = [
        certomancer
        pyhanko-certvalidator
      ];

      pyproject = true;
      pythonRemoveDeps = [ "pyhanko" ];
      sourceRoot = "${finalAttrs.src.name}/internal/common-test-utils";
    };
  };

  meta = {
    description = "Sign and stamp PDF files";
    homepage = "https://github.com/MatthiasValvekens/pyHanko";
    changelog = "https://github.com/MatthiasValvekens/pyHanko/blob/${finalAttrs.src.tag}/docs/changelog.rst#pyhanko";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.antonmosich ];
  };
})
