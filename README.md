Lojban Mediawiki Server
=======================

This repo cotnains the code used to run the Lojban Mediawiki Server, which runs
inside a pair of Docker containers.

This repo by itself won't get you a running system because it doesn't describe
the database.  It's assumed that you're using this along with the data stored
on the web server.

CHECK STUFF IN WHEN YOUR CHANGES ARE DONE!!!
--------------------------------------------

This repo should always have what we're using in production; if you change
something, please check it in!

How To Reach The Server
-----------------------

	$ ssh sampre_mw@jukni.lojban.org 

Login is via ssh key, so if you think you should have access but that doesn't
work, email webmaster@lojban.org or find rlpowell in #lojban on freenode irc.

How To Restart The Server
-------------------------

	$ ./run_docker.sh

That's it.  That will rip down both the database and web containers and restart
them.

How To Test Changes
-------------------

Make whatever changes you want, typically to Dockerfile.web or
LocalSettings.php.in , and run:

	$ ./run_docker.sh -t

This will copy all the data (including the database, so it takes a while) to
the test instance space, and launch a pair of containers to run your changes.
You can reach the test instance at http://test-mw.lojban.org/

How To Install/Upgrade Plugins
------------------------------

All the plugin installation is done in Dockerfile.web (although sometimes
associated changes to LocalSettings.php.in are required).  It should be pretty
obvious what to do in there. Basically, you need to download and unpack the
extension in such a way that the startup in LocalSettings works.  So if in
LocalSettings you add:

	require_once "$IP/extensions/Foo/Foo.php";

then your installation had better have created a directory named Foo/ ,
and not Foo-1.2/ or foo/

How To Interact With The Instances Directly
-------------------------------------------

	$ sudo docker exec -it lojban_mediawiki_web bash

This will give you a shell on the production web instance; modify as
appropriate for other instances.

How To See Instance Logs
------------------------

	$ sudo docker logs lojban_mediawiki_web

This will give you the logs on the production web instance; modify as
appropriate for other instances.
