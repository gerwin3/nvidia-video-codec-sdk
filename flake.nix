{
  description = "openh264";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    zig = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zls = {
      url = "github:zigtools/zls";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    inputs.flake-utils.lib.eachSystem (builtins.attrNames inputs.zig.packages) (
      system:
      let
        overlays = [
          (final: prev: { zigpkgs = inputs.zig.packages.${prev.system}; })
          (final: prev: { zlspkgs = inputs.zls.packages.${prev.system}; })
        ];
        pkgs = import nixpkgs { inherit overlays system; };
      in
      {
        devShells.default = pkgs.mkShell.override { stdenv = pkgs.clangStdenv; } {
          packages = with pkgs; [
            zigpkgs.default
            zls
            cudaPackages.cuda_cudart
          ];

          # The shell hook makes sure that:
          # * `CUDA_PATH` points to the location of `libcudart` and friends.
          #   `CUDA_PATH` is the de facto standard for pointing build scripts to
          #   the CUDA library directory.
          # * If the host is NixOS, we arrange for `libcuda.so` to be linked
          #   correctly by using `LD_LIBRARY_PATH` and `EXTRA_LDFLAGS`. The
          #   preferred way to do it would be to link to the stubs and then use
          #   rpath later (and this is what we'll do when packaging) but for
          #   development it is easier to just directly link to the `nvidia_x11`
          #   package dir, which is assumed to be installed.
          # * Issues a warning for non-NixOS systems.
          shellHook = ''
            export CUDA_PATH=${pkgs.cudaPackages.cuda_cudart}
            if [ -f "/etc/NIXOS" ]; then
              export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.linuxPackages.nvidia_x11}/lib
              export EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib"
            else
              echo "warning: no support for linking libcuda on non-NixOS"
              echo " \`-> refer to https://nixos.wiki/wiki/Nixpkgs_with_OpenGL_on_non-NixOS for more information"
            fi
          '';
        };
      }
    );
}
