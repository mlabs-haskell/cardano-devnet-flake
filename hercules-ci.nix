{ inputs, ... }:
{

  imports = [
    inputs.hci-effects.flakeModule
  ];

  hercules-ci.github-pages.branch = "main";

  perSystem =
    { self', ... }:
    {
      hercules-ci.github-pages.settings.contents = self'.packages.documentaton;
    };
}
