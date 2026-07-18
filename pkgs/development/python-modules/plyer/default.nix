{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  keyring,
  pytestCheckHook,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "plyer";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "kivy";
    repo = "plyer";
    tag = version;
    sha256 = "sha256-7Icb2MVj5Uit86lRHxal6b7y9gIJ3UT2HNqpA9DYWVE=";
  };

  patches = [
    # Fix compatibility with Python 3.13
    (fetchpatch {
      hash = "sha256-rWak2GOGnsw+GhEtdob9h1c39aa6Z1yU7vH9kdGjHO0=";
      name = "0001-plyer-Use-unittest-mock.patch";
      url = "https://github.com/kivy/plyer/commit/c9e73f395e2b51d46ada68119abfae2973591c00.patch";
    })
    (fetchpatch {
      hash = "sha256-omjpQJQ+vZ6T12vL6LvKOuRSihiHfLdEZ1pDat8VuiM=";
      name = "0002-plyer-Remove-whitespace-error-during-self.assertEqual-function-call.patch";
      url = "https://github.com/kivy/plyer/commit/8393c61dfd3a7aa0362d3bf530ba9ca052878c1a.patch";
    })
    (fetchpatch {
      hash = "sha256-Lb7MbbcIjwbfnR8U6t9j0c+bqU7kK3/xEt13pSF8G6M=";
      name = "0003-plyer-Replace obj.__doc__-with-getdoc-obj-to-automatically-remove-new-lines.patch";
      url = "https://github.com/kivy/plyer/commit/675750f31e9f98cd5de2df732afe34648f343d3e.patch";
    })
    (fetchpatch {
      hash = "sha256-ZYYftI4w+21Q6oKm1wku7NJg3xfkIpkjN+PvZY0YjyY=";
      name = "0004-plyer-Remove-newline-and-indentation-comparisons-during-self.assertEqual-function-call.patch";
      url = "https://github.com/kivy/plyer/commit/31e96f689771cd43f0a925463a59fcbc49f58e46.patch";
    })
  ];

  postPatch = ''
    # remove all the wifi stuff. Depends on a python wifi module that has not been updated since 2016
    find -iname "wifi*" -exec rm {} \;
    substituteInPlace plyer/__init__.py \
      --replace-fail "wifi = Proxy('wifi', facades.Wifi)" "" \
      --replace-fail "'wifi', " ""
    substituteInPlace plyer/facades/__init__.py \
      --replace-fail "from plyer.facades.wifi import Wifi" ""
  '';

  propagatedBuildInputs = [ keyring ];

  nativeCheckInputs = [
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  preCheck = ''
    mkdir -p $HOME/.config/ $HOME/Pictures
  '';

  build-system = [
    setuptools
  ];

  disabledTests = [
    # assumes dbus is not installed, it fails and is not very robust.
    "test_notification_notifysend"
    # fails during nix-build, but I am not able to explain why.
    # The test and the API under test do work outside the nix build.
    "test_uniqueid"
  ];

  enabledTestPaths = [ "plyer/tests" ];
  pyproject = true;
  pythonImportsCheck = [ "plyer" ];

  meta = {
    description = "Plyer is a platform-independent api to use features commonly found on various platforms";
    homepage = "https://github.com/kivy/plyer";
    license = lib.licenses.mit;
    broken = stdenv.hostPlatform.isDarwin;

    teams = [
      lib.teams.ngi
    ];
  };
}
