{
  lib,
  fetchFromGitHub,
  mkDiscoursePlugin,
}:

mkDiscoursePlugin {
  src = fetchFromGitHub {
    owner = "angusmcleod";
    repo = "discourse-events";
    rev = "3004435beb0913296dbaf8e5b3cd65be7b84df56";
    sha256 = "sha256-TQ+mcd2IAswxqY6OJfXk+d770WBNBZ73bB2aAfxYSDs=";
  };

  bundlerEnvArgs.gemdir = ./.;
  name = "discourse-events";

  meta = {
    description = "Discourse plugin to manage events";
    homepage = "https://github.com/angusmcleod/discourse-events";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.leona ];
  };
}
