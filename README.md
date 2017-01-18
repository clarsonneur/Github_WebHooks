**RC1** version version supports:

- GH 'push' events
- unlimited number of git repositories
- plain text configuration file



**MINIMUM PRE-REQ.**

- EF tools (or EF server/ or Agent)
- perl v5.10+



**HOW TO SET UP**

_System:_

- Install via CPAN Plack (you can use cpanm)
`$ cpanm Plack`

- Install 'libplack-perl'
`$ sudo apt-get install libplack-perl`

- Test if plack successfully installed
`$ plackup`

- You will see the following:

```
vagrant@commander4:/vagrant/plack/ef_listener$ plackup
Error while loading /vagrant/plack/ef_listener/app.psgi: No such file or directory at (eval 10) line 4.
```

- This is normal

- Depending on your perl distributive, probably, you might need to install several perl libraries additionally:

- JSON (you should install this module under root)
`$ sudo cpanm install JSON`

- String::Compare::ConstantTime


_Github:_

- Log in your github account. Each repository has its own webhooks & services section
- Choose repository which you want to monitor. Go to 'Settings' tab, then to 'Webhooks & services'. Press button 'Add webhook'. You should fill several fields. Before you proceed, generate secret phrase using any tool or just from your mind. Here is a small perl one-liner to do this:

`$ perl -e "print join'', map +(0..9,'a'..'z','A'..'Z')[rand(10+26**2)], 1..20;"`
	
- Note that you should use the same secret phrase for all webhooks and listener configuration

- Enter address of your event listener and port (Payload URL):

`http://192.168.200.1:5000`

- Make sure that GH service can access this address through your firewall.

- Next choose content type as 'application/json'
- Enter secret phrase
- Which events would you like to trigger this webhook?
	- Just the push event
- Event listener will trigger build procedure on every commit
- Set webhook as 'Active'
- Save the webhook


_EF listener:_

- Edit listener configuration file to set up your repositories
	listener.conf 
	- The content of this file organized as block with comments
- Use secret phrase which you generated earlier
- Enter repositories info
	- Name of repository
	- shell/batch file corresponding to current repository
- ef_server section is reserved for future use, so just skip it

- To start listener from command line run the following command:

`plackup ef_listener.psgi`	

- In case if there is no errors, you will see:

```
D:\_source\GitHub_webhooks\src\ef_listener>plackup ef_listener_3.psgi
HTTP::Server::PSGI: Accepting connections at http://0:5000/
```

- every commit will fire webhook and listener will write log such as:

```
192.30.252.40 - - [12/May/2016:21:10:43 +0300] "POST /echo HTTP/1.1" 200 7 "-" "GitHub-Hookshot/375c44e"
```

- In case of necessity you can change listener port using the following syntax:

`plackup --port 6000 ef_listener.psgi`	

- You can stop listener using `control+c` combination any time

- For each repository you should create special shell or batch file which will be used by listener to communicate with EF server. See examples in the package (ec_run_build_A.cmd)


_EF server:_

- You should create a project and build a procedure that will be triggered by the listener. Please edit shell/batch file respectively.


**USAGE**

To start a build sequence just commit to appropriate Github repository. GH will fire webhook on 'push' event, after that GH webhook service will send payload data to listener service, which will execute appropriate shell/batch file that communicates with EF server.