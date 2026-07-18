{
  bork,
  cacert,
  git,
  pytest,
  testers,
}:
{
  # a.k.a. `tests.testers.runCommand.bork`
  pytest-network = testers.runCommand {
    nativeBuildInputs = [
      bork
      cacert
      git
      pytest
    ];

    name = "bork-pytest-network";

    script = ''
      # Copy the source tree over, and make it writeable
      cp -r ${bork.src} bork/
      find -type d -exec chmod 0755 '{}' '+'

      pytest -v -m network bork/
      touch $out
    '';
  };
}
