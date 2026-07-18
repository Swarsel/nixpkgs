{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  # for passthru.tests
  ninja,
  nix-update-script,
  php,
  python3,
  spamassassin,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "re2c";
  version = "4.5.1";

  src = fetchFromGitHub {
    owner = "skvadrik";
    repo = "re2c";
    rev = finalAttrs.version;
    hash = "sha256-POdE8aKvQqfIPEIkUppZPV8t9ApT4R1AyfHXxrKvq88=";
  };

  nativeBuildInputs = [
    autoreconfHook
    python3
  ];

  doCheck = true;

  preCheck = ''
    patchShebangs run_tests.py
  '';

  enableParallelBuilding = true;

  passthru = {
    tests = {
      inherit ninja php spamassassin;
    };

    updateScript = nix-update-script {
      # Skip non-release tags like `python-experimental`.
      extraArgs = [
        "--version-regex"
        "([0-9.]+)"
      ];
    };
  };

  meta = {
    description = "Tool for writing very fast and very flexible scanners";
    homepage = "https://re2c.org";
    license = lib.licenses.publicDomain;
    maintainers = with lib.maintainers; [ thoughtpolice ];
    platforms = lib.platforms.all;
  };
})
