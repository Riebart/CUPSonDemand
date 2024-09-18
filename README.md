# CUPS On Demand

The goal of this project was to have a persistent, containerized CUPS install, with persistent printer configurations. I didn't want to have CUPS running all the time, or deal with `cupsd -l` and `xinetd` or something.


The need I had for this was to periodically print a sheet of full-colour to keep my tank-based inject primed. I don't print often, and so the lines would often end up with air bubbles, and it was a pain to fix. Since a full colour refull is 20 dolalrs, it's "cheaper" and far, far easier to just print a full colour test sheet every whee or so to keep the printer ready for use.


## Usage

It should be pretty much ready to go:

- The `run.sh` is the entrypoint from the host. Step 1 is run it with the port forwarding enabled, then use the `cupsadmin` user and web interface to log in and configure printers. These will be stored into the `etc` directory persistently.
- You can choose to continue to have the port forwarded every time it's running, or not. Your call. I choose to remove the port publishing because my intent is to run it in cron.
- Profit?
