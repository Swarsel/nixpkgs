{
  lib,
  fetchFromGitHub,
  melpaBuild,
  unstableGitUpdater,
}:

melpaBuild {
  pname = "emacs-conflict";
  version = "0-unstable-2022-11-21";

  src = fetchFromGitHub {
    owner = "ibizaman";
    repo = "emacs-conflict";
    rev = "9f236b93930f3ceb4cb0258cf935c99599191de3";
    hash = "sha256-DIGvnotSQYIgHxGxtyCALHd8ZbrfkmdvjLXlkcqQ6v4=";
  };

  passthru.updateScript = unstableGitUpdater { hardcodeZeroVersion = true; };

  meta = {
    description = "Resolve conflicts happening when using file synchronization tools";
    homepage = "https://github.com/ibizaman/emacs-conflict";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ibizaman ];
  };
}
