{
  lib,
  fetchFromGitHub,
  mkDiscoursePlugin,
}:

mkDiscoursePlugin {
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-saved-searches";
    rev = "d13a708d33fc24bb6cc111e8d84fb896caf81ef4";
    sha256 = "sha256-3hnmtHR1k1bZKH3ezauQPr7pfbQYRTbGV8a39w6m6F8=";
  };

  name = "discourse-saved-searches";

  meta = {
    description = "Allow users to save searches and be notified of new results";
    homepage = "https://github.com/discourse/discourse-saved-searches";
    license = lib.licenses.mit;
  };
}
