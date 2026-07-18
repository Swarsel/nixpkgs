{
  lib,
  fetchFromGitHub,
  fetchpatch,
  python3,
}:

python3.pkgs.buildPythonApplication {
  pname = "dnd-tools";
  version = "0-unstable-2021-02-18";

  src = fetchFromGitHub {
    owner = "savagezen";
    repo = "dnd-tools";
    rev = "baefb9e4b4b8279be89ec63d256dde9704dee078";
    sha256 = "1rils3gzbfmwvgy51ah77qihwwbvx50q82lkc1kwcb55b3yinnmj";
  };

  # gives warning every time unless patched, see https://github.com/savagezen/dnd-tools/pull/20
  patches = [
    (fetchpatch {
      sha256 = "00k8rsz2aj4sfag6l313kxbphcb5bjxb6z3aw66h26cpgm4kysp0";
      url = "https://github.com/savagezen/dnd-tools/commit/0443f3a232056ad67cfb09eb3eadcb6344659198.patch";
    })
  ];

  build-system = with python3.pkgs; [
    setuptools
  ];

  pyproject = true;

  meta = {
    description = "Set of interactive command line tools for Dungeons and Dragons 5th Edition";
    homepage = "https://github.com/savagezen/dnd-tools";
    license = lib.licenses.agpl3Only;
    maintainers = [ ];
    mainProgram = "dnd-tools";
  };
}
