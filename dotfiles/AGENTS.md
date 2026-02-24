## Env tips
1. My entire config/environment setup is controlled by nix in ~/.config/nix.
    a. For all changes that need to be done to brew please add it to brews with clear comments as to why its added/ needed.
    b. For all config changes to my fish shell or neovim please edit the files in dotfiles.
    c. run `hms` to sync changes.
2. My main shell is fish.

## Dev Change tips
ALWAYS, ALWAYS and I mean ALWAYS test code before telling the user it's ready.
If you are not sure how to test the code ask the user.

please avoid these big comment structural blocks
```
// =========================================================================
// Tests — SlotAllocator with payload data
// =========================================================================
```
they are ugly and unwanted.
