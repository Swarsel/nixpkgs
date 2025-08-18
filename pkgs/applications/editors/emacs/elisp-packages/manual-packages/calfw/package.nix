{
  lib,
  fetchFromGitHub,
  trivialBuild,
  howm,
}:

trivialBuild rec {
  pname = "calfw";
  version = "0-unstable-2025-05-02";
  src = fetchFromGitHub {
    owner = "haji-ali";
    repo = "emacs-calfw";
    rev = "de99e8e848ee03811388f433f7eb0400976b791d";
    hash = "sha256-Wu7rKM72/umFqXNMmQ5lY/C/EhXPRCLzo6K/J0f1t70=";
  };

  packageRequires = [ howm ];

  meta = {
    homepage = "https://github.com/kiwanami/emacs-calfw";
    description = "A calendar framework for Emacs";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [
      swarsel
    ];
  };
}
