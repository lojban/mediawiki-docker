Lojban Mediawiki Server
=======================

This is the containerized service infrastructure for the Lojban
Mediawiki Server.

This repo by itself won't get you a running system because it
doesn't have the contents of the data/ directories.

This is an LBCS instance (see https://github.com/lojban/lbcs/ ),
which is why a bunch of things in here are symlinks off into
apparently empty space; you have to have LBCS installed in
/opt/lbcs/ for them to work.

That's also where the docs on how to like start and stop the service
and so on are.

CHECK STUFF IN WHEN YOUR CHANGES ARE DONE!!!
--------------------------------------------

This repo should always have what we're using in production; if you change
something, please check it in!

General Note On MW Web Configuration
------------------------------------

Much of the mediawiki config is in LocalSettings.php.erb ; in
particular, it's very important to understand $wgScriptPath and
$wgArticlePath and how they relate.  Normally the mw code (i.e.
$wgScriptPath) is a *subdir* of the document root, although that's
not what we're doing here.  See
http://www.mediawiki.org/wiki/Manual:Short_URL and
http://www.mediawiki.org/wiki/Manual:Short_URL/Apache

How To Install/Upgrade Plugins
------------------------------

All the plugin installation is done in
containers/web\*/Dockerfile.web (although sometimes associated
changes to containers/web\*/misc/LocalSettings.php.erb  are
required).  It should be pretty obvious what to do in there.
Basically, you need to download and unpack the extension in such a
way that the startup in LocalSettings works.  So if in LocalSettings
you add:

	require_once "$IP/extensions/Foo/Foo.php";

then your installation had better have created a directory named Foo/ ,
and not Foo-1.2/ or foo/

How To Test Changes
-------------------

There are db-test and web-test containers.  Typically you'd be
testing changes to containers/web-test/Dockerfile.erb or
containers/web-test/misc/LocalSettings.php.erb .  Make your changes
and do something like this:

        $ systemctl --user restart db-test web-test ; journalctl --user -f -n 50 

How To Check The Test Configurations
------------------------------------

You can check for differences between the prod and test
configurations like so:

        $ ./diff_test.sh web
        $ ./diff_test.sh db

Some things are expected, such as the web server being on port 8080,
or the host name being mw-test, or the db server being on port 3307.
You're looking for any changes you *didn't* intend; the goal is to
change only the configs you intended and control config drift.

Refreshing Test Data
--------------------

To get the latest data into the test containers, run:

        $ ./sync_test.sh web
        $ ./sync_test.sh db

If you want the db one to work properly, though, you need to stop
the normal db container.

General System Status Check
---------------------------

	$ systemctl --user list-units --no-page -t service -a

How To Interact With The Instances Directly
-------------------------------------------

	$ podman exec -it web bash

This will give you a shell on the production web instance; modify as
appropriate for other instances.

How To See Instance Logs
------------------------

	$ journalctl --user -n 50 -f

This will give you the logs on all instances; to get just the
production web instance use:

	$ journalctl --user -n 50 -f -u web
