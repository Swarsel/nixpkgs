{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  nix-update-script,
  python3,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libvarlink";
  version = "24.0.1";

  src = fetchFromGitHub {
    owner = "varlink";
    repo = "libvarlink";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-MO5wfmPAm90AD+Y+vYqZynB4A18/XtJ1cys+lIIwbTY=";
  };

  postPatch = ''
    # test-object: ../lib/test-object.c:129: main: Assertion `setlocale(LC_NUMERIC, "de_DE.UTF-8") != 0' failed.
    # PR that added it https://github.com/varlink/libvarlink/pull/27
    substituteInPlace lib/test-object.c \
      --replace 'assert(setlocale(LC_NUMERIC, "de_DE.UTF-8") != 0);' ""

    patchShebangs lib/test-symbols.sh varlink-wrapper.py

    # They forgot to update the version
    substituteInPlace meson.build \
      --replace-fail "24.0.0" "${finalAttrs.version}"
  '';

  nativeBuildInputs = [
    meson
    ninja
    python3
  ];

  doCheck = true;

  passthru = {
    tests = {
      version = testers.testVersion {
        command = "varlink --version";
        package = finalAttrs.finalPackage;
      };
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "C implementation of the Varlink protocol and command line tool";
    homepage = "https://github.com/varlink/libvarlink";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ artturin ];
    platforms = lib.platforms.linux;
    mainProgram = "varlink";
  };
})
