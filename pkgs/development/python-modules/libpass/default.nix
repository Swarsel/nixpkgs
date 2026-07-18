{
  lib,
  fetchFromGitHub,
  argon2-cffi,
  bcrypt,
  buildPythonPackage,
  cryptography,
  hatchling,
  pytest-archon,
  pytest-xdist,
  pytestCheckHook,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "libpass";
  version = "1.9.3";

  src = fetchFromGitHub {
    owner = "ThirVondukr";
    repo = "passlib";
    tag = version;
    hash = "sha256-fzI9HpGE3wNK41ZSOeA5NAr5T4r3Jzdqe5+SHoWVXUs=";
  };

  nativeCheckInputs = [
    pytest-archon
    pytest-xdist
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ hatchling ];

  disabledTestPaths = [
    # https://github.com/notypecheck/passlib/issues/18
    "tests/test_handlers_bcrypt.py::bcrypt_bcrypt_test::test_70_hashes"
    "tests/test_handlers_bcrypt.py::bcrypt_bcrypt_test::test_77_fuzz_input"
    "tests/test_handlers_django.py::django_bcrypt_test::test_77_fuzz_input"
    "tests/test_handlers_bcrypt.py::bcrypt_bcrypt_test::test_secret_w_truncate_size"
    "tests/test_handlers_django.py::django_bcrypt_test::test_secret_w_truncate_size"
  ];

  disabledTests = [
    # timming sensitive
    "test_dummy_verify"
    "test_encrypt_cost_timing"
  ];

  optional-dependencies = {
    argon2 = [ argon2-cffi ];
    bcrypt = [ bcrypt ];
    totp = [ cryptography ];
  };

  pyproject = true;
  pythonImportsCheck = [ "passlib" ];

  meta = {
    description = "Comprehensive password hashing framework supporting over 30 schemes";
    homepage = "https://github.com/ThirVondukr/passlib";
    changelog = "https://github.com/ThirVondukr/passlib/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
