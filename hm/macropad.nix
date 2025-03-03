{ pkgs, lib, ... }:

pkgs.buildGoModule rec {
  pname = "macro_go";
  version = "0.1.2";

  src = pkgs.fetchFromGitHub {
    owner = "PJalv";
    repo = "macropad";
    rev = "a2503e7f57f34c240763b532f6e3036d333f4c37";
    hash = "sha256-h75Fkw3R8mNdt7imamIpfuzsyYP66BT0Nv5UPAnabRo=";
  } + "/macro_go";

  vendorHash = "sha256-wSrY7GIXYcLh6iuhMKu8gqSsXUWj8CdBvMDgT3bH18o=";
  proxyVendor = true;
  meta = {
    description = "PJalv's Macropad Project";
    homepage = "https://github.com/PJalv/macropad";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ PJalv ];
  };
}
