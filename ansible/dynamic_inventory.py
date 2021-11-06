#!/usr/bin/python3
import argparse
import sys
import json

TERRAFORM_JSON_SOURCE = 'terraform_output.json'

def list_inventory():
    inventory = {}

    app_hosts = []
    db_hosts = []

    with open(TERRAFORM_JSON_SOURCE) as source:
        data = json.load(source)
        for k, v in data['values']['outputs'].items():
            if 'db' in k:
                db_hosts.append(v['value'])
            elif 'app' in k:
                app_hosts.append(v['value'])
            else:
                raise NotImplemented('Unexpected output variable name: {}'.format(k))

    if len(app_hosts):
        inventory['app'] = {}
        inventory['app']['hosts'] = app_hosts

    if len(db_hosts):
        inventory['db'] = {}
        inventory['db']['hosts'] = db_hosts

    return inventory


def list_host_variables():
    return {}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Dynamic inventory for Otus DevOps course.')
    parser.add_argument('--list', action='store_true', default=False, help='Show all available lists')
    parser.add_argument('--host', help='Hostname to get variables')
    args = parser.parse_args()

    if args.list and args.host:
        print ('--list and --host are mutually exclusive options')
        sys.exit(1)

    if not args.list and not args.host:
        print ('No valid options passed (should be one of: --list/--host <name>)')
        sys.exit(1)

    output = {}
    if args.list:
        output = list_inventory()
    else:
        pass  # nothing to do here

    print(json.dumps(output, indent=2, sort_keys=True))
