{
  lib,
  stdenv,
  fetchFromGitHub,
  nixosTests,
  python3Packages,
  radicale,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "etesync-dav";
  version = "0.35.1";

  src = fetchFromGitHub {
    owner = "etesync";
    repo = "etesync-dav";
    tag = "v${finalAttrs.version}";
    hash = "sha256-y4BhU2kSn+RWqc5+pJQFhbwfat9cMWD0ED0EXJp25cY=";
  };

  patches = [
    # https://github.com/etesync/etesync-dav/pull/365
    ./radicale-3-6-compat.patch
  ];

  doCheck = false;
  build-system = with python3Packages; [ setuptools ];

  dependencies =
    with python3Packages;
    [
      appdirs
      etebase
      etesync
      flask
      flask-wtf
      msgpack
      (python3Packages.toPythonModule (radicale.override { python3 = python; }))
      requests
    ]
    ++ requests.optional-dependencies.socks;

  pyproject = true;
  pythonRelaxDeps = [ "radicale" ];

  passthru.tests = {
    inherit (nixosTests) etesync-dav;
  };

  meta = {
    description = "Secure, end-to-end encrypted, and privacy respecting sync for contacts, calendars and tasks";
    homepage = "https://www.etesync.com";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      valodim
    ];

    mainProgram = "etesync-dav";
    broken = stdenv.hostPlatform.isDarwin; # pyobjc-framework-Cocoa is missing
  };
})
