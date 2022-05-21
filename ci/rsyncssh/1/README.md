Actions Configuration
==================
This action combines rsync and ssh steps.  It only supports running an SSH command. You probably want to configure command= in your authorized_keys anyway, for security.

Your step configuration will look something like:
```
    steps:
    - name: Checkout the repo
      uses: actions/checkout@v1

    # Conditionally deploy to dev server, if pushed to development
    - name: Deploy Development
      if: github.ref == 'refs/heads/development'
      uses: docker://ghcr.io/university-of-york/sys-docker-images/ci/rsyncssh:1
      env:
        SERVER: ${{ secrets.DEPLOY_SSH_HOST_DEV }}
        RSYNC_USER: 'cdeploy-rsync'
        SSH_USER: 'cdeploy-ssh'
        RSYNC_ARGS: '--exclude=/vendor --exclude=/.bundle'
        SSH_KEY: ${{ secrets.DEPLOY_SSH_PRIVATE_KEY }}
```

The following parameters are required and MUST be specified:

* SERVER: Configures the (fully qualified) hostname of the server you intend to deploy to.

* SSH_KEY: The full RSA SSH Private key used to deploy. Pass this through as a Github secret. OpenSSH private keys are not supported.

* RSYNC_USER: The RSYNC SSH user to use on the destination machine.

* SSH_USER: The SSH user to use on the destination machine.

The following parameters are optional:

* LOCAL_PATH: Configures which directory is rsynced from.  The default
  is the current directory "./" which is the root of the repository.

* REMOTE_PATH: Configures which directory is rsynced to.  The default
  is the root directory "/" - I assume you'll set up rrsync which will
  automatically map this to your deployment directory.

* COMMAND: Specifies the command for SSH to run.  The default is false,
  as I expect you'll set the deployment command using command= in your
  authorized_keys file.

* CHMOD: Specifies how file permissions are set on the deployed copy;
  the default is g-w,o-rwx for security, which will normally leave your
  code checked out RW for the rsync user and RO for its group, with no
  access from other accounts.

* RSYNC_ARGS: Any extra options you want for rsync, for example to
  exclude certain directories.

Caveats
============

* The SSH configuration, as it doesn't know about any known hosts, has StrictHostKeyChecking disabled.

* OpenSSH private keys currently do not work.

These will hopefully be fixed in some capacity moving forward.

How to Build
============

This is configured to push automatically to Github Packages.
