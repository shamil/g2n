## g2n - Ganglia to Nagios

This script will get all hosts from Ganglia (gmetad) and convert to Nagios configs. The convertion done using template mappings.

**Getting started:**

> Look in `config.example/*` for reference

1. Set all required config settings in `config/g2n.yml`. 
2. Edit the `config/mappings.yml` to map Ganglia cluster to Nagios templates (located by default in `config/templates`)
3. Run the `g2n` (for example: `cd <project-dir>; ruby -Ilib bin/g2n`, to generate the Nagios configs and put them into `output_path` (default is: `/var/tmp/g2n`)
4. Finally copy the generated Nagios configs to nagios configuration dir. (e.g. `/etc/nagios`)

**Example sync script:**

* There is an example script (located in `scripts/sync.sh`) which can be used in cronjobs.
* The script will run `g2n` and copy the generated configs into Nagios configuration folder.
* After copying it will restart Nagios daemon, in order for the changes to take effect.
* The script will check for changes before copying the generated configs to Nagios configuration directory and before restarting Nagios daemon. So when no changes found, the sync script won't do any restarts to Nagios daemon.

> FYI: edit the sync script and change the `NAGIOS_CFG_DIR` variable to desired Nagios configuration directory

**while developing, run the script like this:**

```shell
cd <project-dir>
ruby -Ilib bin/g2n
```

**license**

[DO WHATEVER THE FUCK YOU WANT, PUBLIC LICENSE](http://wtfpl.org)
