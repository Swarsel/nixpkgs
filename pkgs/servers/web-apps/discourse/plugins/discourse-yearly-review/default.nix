{
  lib,
  fetchFromGitHub,
  mkDiscoursePlugin,
}:

mkDiscoursePlugin {
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-yearly-review";
    rev = "7e7df7878212ad976031cbbc17a0dd4ca1d55def";
    sha256 = "sha256-+6CmXgXEyQb6CNSqaVqbfXQCc+XJQGDQnw9vgAlse0g=";
  };

  name = "discourse-yearly-review";

  meta = {
    description = "Publishes an automated Year in Review topic";
    homepage = "https://github.com/discourse/discourse-yearly-review";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ talyz ];
  };
}
