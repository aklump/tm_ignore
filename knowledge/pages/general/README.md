<!--
id: readme
tags: ''
-->

# Time Machine Ignore

![tm_ignore](../../images/tm-ignore.jpg)

## Summary

Easily ignore a project's files and folders from Time Machine backups using a YAML config.

**Visit <https://aklump.github.io/tm_ignore> for full documentation.**

## Quick Start

- Install in your repository root using `cloudy pm-install aklump/tm_ignore`
- Open _bin/config/tm_ignore.yml_ and add all the paths you wish to be ignored by Time Machine.
- Apply your changes to TM with `./bin/tm_ignore`
- Use `./bin/tm_ignore help` for other featurs.

## Requirements

You must have [Cloudy](https://github.com/aklump/cloudy) installed on your system to install this package.

## Installation

The installation script above will generate the following structure where `.` is your repository root.

    .
    ├── bin
    │   ├── tm_ignore -> ../opt/tm_ignore/tm_ignore.sh
    │   └── config
    │       ├── tm_ignore.yml
    ├── opt
    │   ├── cloudy
    │   └── aklump
    │       └── tm_ignore
    └── {public web root}

### To Update

- Update to the latest version from your repo root: `cloudy pm-update aklump/tm_ignore`

## Configuration Files

Refer to the file(s) for documentation about configuration options.

| Filename | Description | VCS |
|----------|----------|---|
| _tm_ignore.yml_ | Configuration shared across all server environments: prod, staging, dev  | yes |

## Usage

* To see all commands use `./bin/tm_ignore help`

## Under the Hood
* This package uses the built in `tmutil` utility.  This controls Time Machine via the CLI.  For example to exclude any system path use `tmutil addexclusion <path>`. The undo the exclusion, use `tmutil removeexclusion <path>`.

## Contributing

If you find this project useful... please consider [making a donation](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=4E5KZHDQCEUV8&item_name=Gratitude%20for%20aklump%2Ftm_ignore).

## Credits

* Inspiration and code was taken from [Asimov](https://github.com/stevegrunwell/asimov), thank you Steve.
