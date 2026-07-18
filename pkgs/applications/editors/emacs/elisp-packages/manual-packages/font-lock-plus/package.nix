{
  lib,
  fetchFromGitHub,
  melpaBuild,
}:

melpaBuild {
  pname = "font-lock-plus";
  version = "208-unstable-2022-04-02";

  src = fetchFromGitHub {
    owner = "emacsmirror";
    repo = "font-lock-plus";
    rev = "aa1c82d05c9222b09099a0ccd7468e955497940c";
    hash = "sha256-er+knxqAejgKAtOnhqHfsGN286biHFdeMIUlbW7JyYw=";
  };

  ename = "font-lock+";

  meta = {
    description = "Enhancements to standard library font-lock.el";
    homepage = "https://github.com/emacsmirror/font-lock-plus";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
  };
}
