{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "ldapmonitor";
  version = "1.4";

  src = fetchFromGitHub {
    owner = "p0dalirius";
    repo = "ldapmonitor";
    tag = finalAttrs.version;
    hash = "sha256-BmTj/6dOUYfia6wO4nvkEW01MIC9TuBk4kYAsVHMsWY=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    impacket
    ldap3
    python-ldap
  ];

  installPhase = ''
    runHook preInstall

    install -vD pyLDAPmonitor.py $out/bin/ldapmonitor

    runHook postInstall
  '';

  pyproject = false;
  sourceRoot = "${finalAttrs.src.name}/python";

  meta = {
    description = "Tool to monitor creation, deletion and changes to LDAP objects";
    homepage = "https://github.com/p0dalirius/LDAPmonitor";
    changelog = "https://github.com/p0dalirius/LDAPmonitor/releases/tag/${finalAttrs.version}";
    license = with lib.licenses; [ gpl3Only ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "ldapmonitor";
  };
})
