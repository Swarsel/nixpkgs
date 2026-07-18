{
  lib,
  fetchFromGitHub,
  gzip,
  melpaBuild,
  unstableGitUpdater,
}:

melpaBuild {
  pname = "edraw";
  version = "1.2.0-unstable-2025-05-23";

  src = fetchFromGitHub {
    owner = "misohena";
    repo = "el-easydraw";
    rev = "8007f50c1c1734325c47939904f486753c7dd8ee";
    hash = "sha256-YESpl+gSSC1eIOEQ8QevfTZ0Ar9wO4pzC12wVmDpDOA=";
  };

  files = ''(:defaults "msg")'';
  propagatedUserEnvPkgs = [ gzip ];

  meta = {
    description = "Embedded drawing tool for Emacs";
    homepage = "https://github.com/misohena/el-easydraw";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ brahyerr ];
  };
}
