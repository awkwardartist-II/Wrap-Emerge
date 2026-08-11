# Wrap Emerge: A Hook Wrapper

This is just a wrapper for emerge which allows you define hooks.

## How to Define Hooks

To define a hook when dev-vcs/git is set up, in `/etc/portage/hook/gitsetup.sh`:

```bash
#post_pkg_setup

einfo 'Git has been set up!'
```
And then in `/etc/portage/package.hook/git`:

```
dev-vcs/git gitsetup
```

With these files present, portage will execute gitsetup.sh in post_pkg_setup. 

## How to Install

Place 'bashrc' at /etc/portage/bashrc, and 'wrap-emerge' on your `$PATH`. I'd recommend also using an alias to map the emerge command to the wrapper:

`alias emerge='wrap-emerge'`

**This software was created by man, not machine**
