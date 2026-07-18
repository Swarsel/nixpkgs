{
  lib,
  fetchFromGitHub,
  bash,
  coreutils,
  nixosTests,
  openssl,
  python312,
  udevCheckHook,
}:

let
  python = python312;

in
python.pkgs.buildPythonApplication (finalAttrs: {
  pname = "waagent";
  version = "2.15.0.1";

  src = fetchFromGitHub {
    owner = "Azure";
    repo = "WALinuxAgent";
    tag = "v${finalAttrs.version}";
    hash = "sha256-P+jxn0W8LaTxDcvKlWjCK1Z9X1l/jf1s41bO9N34N0Q=";
  };

  patches = [
    # Suppress the following error when waagent tries to configure sshd:
    # Read-only file system: '/etc/ssh/sshd_config'
    ./dont-configure-sshd.patch
  ];

  # Replace tools used in udev rules with their full path and ensure they are present.
  postPatch = ''
    substituteInPlace config/66-azure-storage.rules \
      --replace-fail readlink '${coreutils}/bin/readlink' \
      --replace-fail cut '${coreutils}/bin/cut' \
      --replace-fail '/bin/sh' '${bash}/bin/sh'
    substituteInPlace config/99-azure-product-uuid.rules \
      --replace-fail '/bin/chmod' '${coreutils}/bin/chmod'
    substituteInPlace azurelinuxagent/common/conf.py \
      --replace-fail '/usr/bin/openssl' '${openssl}/bin/openssl'
  '';

  nativeBuildInputs = [
    udevCheckHook
  ];

  doInstallCheck = true;

  # The udev rules are placed to the wrong place.
  # Move them to their default location.
  # Keep $out/${python.sitePackages}/usr/sbin/waagent where it is.
  # waagent re-executes itself in UpdateHandler.run_latest, even if autoupdate
  # is disabled, manually spawning a python interprever with argv0.
  # We can't use the default python program wrapping mechanism, as it uses
  # wrapProgram which doesn't support --argv0.
  # So instead we make our own wrapper in $out/bin/waagent, setting PATH and
  # PYTHONPATH.
  # PATH contains our PYTHON, and PYTHONPATH stays set, so this should somewhat
  # still work.
  preFixup = ''
    mv $out/${python.sitePackages}/etc $out/

    buildPythonPath

    mkdir -p $out/bin
    makeWrapper $out/${python.sitePackages}/usr/sbin/waagent $out/bin/waagent \
      --set PYTHONPATH $PYTHONPATH \
      --prefix PATH : $program_PATH \
      --argv0 $out/${python.sitePackages}/usr/sbin/waagent
  '';

  build-system = with python.pkgs; [ setuptools ];
  dependencies = with python.pkgs; [ distro ];
  dontWrapPythonPrograms = false;
  pyproject = true;

  passthru.tests = {
    inherit (nixosTests) waagent;
  };

  meta = {
    description = "Microsoft Azure Linux Agent (waagent)";

    longDescription = ''
      The Microsoft Azure Linux Agent (waagent)
      manages Linux provisioning and VM interaction with the Azure
      Fabric Controller'';

    homepage = "https://github.com/Azure/WALinuxAgent";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ codgician ];
    platforms = lib.platforms.linux;
    mainProgram = "waagent";
  };
})
