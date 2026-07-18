{
  lib,
  stdenv,
  fetchFromGitHub,
  libcap,
  udevCheckHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "cpu-energy-meter";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "sosy-lab";
    repo = "cpu-energy-meter";
    rev = finalAttrs.version;
    hash = "sha256-QW65Z8mRYLHcyLeOtNAHjwPNWAUP214wqIYclK+whFw=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace "DESTDIR :=" "DESTDIR := $out" \
      --replace "PREFIX := /usr/local" "PREFIX :="
  '';

  nativeBuildInputs = [
    udevCheckHook
  ];

  buildInputs = [ libcap ];
  env.NIX_CFLAGS_COMPILE = "-fcommon";

  postInstall = ''
    install -Dm444 -t $out/etc/udev/rules.d $src/debian/additional_files/59-msr.rules
  '';

  doInstallCheck = true;

  meta = {
    description = "Tool for measuring energy consumption of Intel CPUs";
    homepage = "https://github.com/sosy-lab/cpu-energy-meter";
    changelog = "https://github.com/sosy-lab/cpu-energy-meter/blob/main/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ lorenzleutgeb ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "cpu-energy-meter";
  };
})
