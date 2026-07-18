{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  nixosTests,
  nss_latest,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "firefox_decrypt";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "unode";
    repo = "firefox_decrypt";
    tag = finalAttrs.version;
    hash = "sha256-Y958qXGpkNgMBYiM80OKQYkO7EdqH7T5FfINELAB9CY=";
  };

  checkPhase = ''
    runHook preCheck

    patchShebangs tests
    (cd tests && ${if stdenv.hostPlatform.isDarwin then "DYLD_LIBRARY_PATH" else "LD_LIBRARY_PATH"}=${
      lib.makeLibraryPath [ nss_latest ]
    } ./run_all)

    runHook postCheck
  '';

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
    wheel
  ];

  makeWrapperArgs = [
    "--prefix"
    (if stdenv.hostPlatform.isDarwin then "DYLD_LIBRARY_PATH" else "LD_LIBRARY_PATH")
    ":"
    (lib.makeLibraryPath [ nss_latest ])
  ];

  pyproject = true;

  passthru = {
    tests = {
      inherit (nixosTests) firefox_decrypt;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Tool to extract passwords from profiles of Mozilla Firefox and derivates";
    homepage = "https://github.com/unode/firefox_decrypt";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      schnusch
      unode
    ];

    mainProgram = "firefox-decrypt";
  };
})
