opsworks-shoryuken
================

Opsworks shoryuken cookbook for Ubuntu and Rails or non-rails shoryuken deploys

## Installation instructions

1) Make sure you have Redis installed.  This cookbook seems decent: https://github.com/brianbianco/redisio

2) Add this cookbook to your list of Custom Cookbooks

3) Add the deploy recipe in this cookbook to your Application's Deploy custom recipe.  This should be place AFTER your application is deployed to ensure shoryuken uses the new code checked out.

4) Configure your shoryuken custom JSON to specify shoryuken should be deployed with this app:


### Supported Options

Currently supported options for the shoryuken deploy recipe are:

* start_command

The command to start shoryuken.  This will run relative to the root of the current release path.

Defaults to:

```bash
bundle exec shoryuken -e production -C config/shoryuken.yml -r ./config/boot.rb 2>&1 >> log/shoryuken.log
```

### Sample Chef JSON configuration

Here is an example Custom JSON which overrides overrides the start_command to set the shoryuken environment to staging:

```json
{
  "deploy": {
    "YOURAPPNAME": {
      "shoryuken": {
        "start_command": "bundle exec shoryuken -e staging -C config/shoryuken.yml -r ./config/boot.rb 2>&1 >> log/shoryuken.log"
      }
    }
  }
}
```

Here is the minimum deploy config required:
```json
{
  "deploy": {
    "YOURAPPNAME": {
      "shoryuken": {}
    }
  }
}
```

### Environment variables

All Opsworks environment_variables defined within your application will be exposed to the shoryuken process via the upstart script.
