{
  lib,
  fetchFromGitHub,
  openssh,
  python3Packages,
  rsync,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "pssh";
  version = "2.3.6";

  src = fetchFromGitHub {
    owner = "lilydjwg";
    repo = "pssh";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KG/7sHJn++eQ/tRT5pMeWDYxkf/Rk5q1x73fQoBdyx4=";
  };

  postPatch = ''
    for f in bin/*; do
      substituteInPlace $f \
        --replace "'ssh'" "'${openssh}/bin/ssh'" \
        --replace "'scp'" "'${openssh}/bin/scp'" \
        --replace "'rsync'" "'${rsync}/bin/rsync'"
    done
  '';

  # Tests do not run with python3: https://github.com/lilydjwg/pssh/issues/126
  doCheck = false;
  build-system = with python3Packages; [ setuptools ];
  pyproject = true;

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Parallel SSH Tools";

    longDescription = ''
      PSSH provides parallel versions of OpenSSH and related tools,
      including pssh, pscp, prsync, pnuke and pslurp.
    '';

    changelog = "https://github.com/lilydjwg/pssh/blob/${finalAttrs.src.tag}/ChangeLog";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ chris-martin ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
